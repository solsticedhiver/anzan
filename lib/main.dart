import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:anzan/display.dart';
import 'package:anzan/history.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mp3_info/mp3_info.dart';

import 'config.dart';
import 'locale_web.dart' if (dart.library.io) 'locale_platform.dart';
import 'posthog.dart';
import 'settings.dart';

bool _hasWarningBeenShown = false;
bool _hasMediaKitBeenInitialized = false;
final prefs = SharedPreferencesAsync();

int compareVersion(String v1, String v2) {
  var v1s = v1.split('.');
  var v2s = v2.split('.');
  int sign = 1;
  if (v2s.length > v1s.length) {
    List<String> tmp = v2s.toList();
    v2s = v1s.toList();
    v1s = tmp;
    sign = -1;
  }
  int n, m;
  for (var i = 0; i < v1s.length; i++) {
    n = int.parse(v1s[i]);
    if (i > v2s.length - 1) {
      m = 0;
    } else {
      m = int.parse(v2s[i]);
    }
    if (n > m) {
      return -1 * sign;
    } else if (n < m) {
      return sign;
    }
  }
  return 0;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    MediaKit.ensureInitialized();
    _hasMediaKitBeenInitialized = true;
  } catch (e) {
    debugPrint(e.toString());
  }

  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  } else {
    AppConfig.host = 'http://127.0.0.1:5000';
    if (kIsWeb) {
      AppConfig.host = "http://localhost:5000";
    } else if (Platform.isAndroid) {
      AppConfig.host = "http://10.0.2.2:5000";
    }
  }

  AppConfig.locale = detectedSystemLocale;
  await getSettings(prefs);

  String source = 'unknown';
  if (kIsWeb) {
    source = 'web';
  } else if (Platform.isWindows) {
    source = 'windows';
  } else if (Platform.isAndroid) {
    source = 'android';
  } else if (Platform.isLinux) {
    source = 'linux';
  } else if (Platform.isMacOS) {
    source = 'macOS';
  } else if (Platform.isIOS) {
    source = 'IOS';
  }
  AppConfig.platform = '${source.substring(0, 1).toUpperCase()}${source.substring(1)}';
  AppConfig.userAgent = AppConfig.userAgent.replaceAll('platform', AppConfig.platform);

  // check pref first
  if (AppConfig.distinctId.isEmpty) {
    AppConfig.distinctId = getDistinctId();
    await prefs.setString('distinctId', AppConfig.distinctId);
  }

  if (kReleaseMode && AppConfig.isTelemetryAllowed) {
    posthog(AppConfig.distinctId, 'app_started', {'source': source, 'version': AppConfig.appVersion});
  } else {
    debugPrint(
        "posthog('${AppConfig.distinctId}', 'app_started', {'source': $source, 'version': ${AppConfig.appVersion}});");
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => NumberModel()),
      ChangeNotifierProvider(create: (context) => ThemeModeModel()),
    ],
    child: MyApp(prefs),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp(SharedPreferencesAsync prefs, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeModel>(builder: (context, tMM, child) {
      return MaterialApp(
        title: 'Mental Calculation',
        theme: ThemeData(colorScheme: const ColorScheme.light(primary: green, secondary: lightBrown)),
        darkTheme: ThemeData(colorScheme: const ColorScheme.dark(primary: lightGreen, secondary: lightBrown)),
        themeMode: tMM.themeMode,
        home: const MyHomePage(title: 'Anzan'),
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _indx = 0;
  bool isReplayable = false;
  bool isPlaying = false;
  List<int> numbers = [];
  List<Uint8List> sounds = [];
  late TextStyle style;
  late Player? player;
  TextEditingController textEditingController = TextEditingController();
  late FocusNode myFocusNode;
  Timer? t1, t2;
  bool isPlayButtonDisabled = false;
  RichText answerText = RichText(text: const TextSpan(text: ''));

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
    if (_hasMediaKitBeenInitialized) {
      player = Player();
    } else {
      player = null;
      AppConfig.useTTS = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<ThemeModeModel>(context, listen: false).setThemeMode(AppConfig.themeMode);

      try {
        final req = await http.get(Uri.parse('${AppConfig.host}/tools/tts?lang_list=1&version=1'), headers: {
          'User-Agent': AppConfig.userAgent,
          'X-Distinct-ID': AppConfig.distinctId
        }).timeout(const Duration(seconds: 5));
        if (req.statusCode == 200) {
          final resp = json.decode(req.body);
          for (var l in resp['languages']) {
            AppConfig.languages.add(l);
          }
          //debugPrint(AppConfig.languages.toString());
          final version = resp['version'];
          if (AppConfig.updateNotificationCount < 3 && compareVersion(AppConfig.appVersion, version) == 1) {
            // show a dialog about the new version
            if (context.mounted) {
              const redOnDark = Color.fromARGB(255, 0xF3, 0x74, 0x74);
              const redOnLight = Color.fromARGB(255, 0xBD, 0x37, 0x37);
              Color red = redOnDark;
              if (Theme.of(context).scaffoldBackgroundColor.computeLuminance() < 0.179) {
                red = redOnLight;
              }
              if (!kIsWeb) {
                AppConfig.updateNotificationCount += 1;
                await prefs.setInt('updateNotificationCount', AppConfig.updateNotificationCount);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      duration: const Duration(seconds: 30),
                      content: Center(
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Text('A new release is available'),
                        const SizedBox(width: 15),
                        Icon(Icons.new_releases, color: red)
                      ])),
                      showCloseIcon: true,
                      action: SnackBarAction(
                          label: 'Go to website',
                          textColor: red,
                          onPressed: () {
                            launchUrl(Uri.parse('https://www.sorobanexam.org/anzan.html'));
                          })),
                );
              }
            }
          }
        }
      } catch (e) {
        AppConfig.useTTS = false;
        debugPrint(e.toString());
      }

      if (!_hasWarningBeenShown && (AppConfig.languages.isEmpty || !_hasMediaKitBeenInitialized)) {
        _hasWarningBeenShown = true;
        String title, content;
        if (!_hasMediaKitBeenInitialized) {
          title = 'Error initliazing MediaKit library';
          content = 'This usually means the libmpv library has not been found. Check your installation of libmpv.\n'
              'TTS will be disabled';
        } else {
          title = 'Error fetching the TTS languages list';
          content = 'There was a network error while retrieving the language TTS list. TTS will be disabled.\n'
              'Relaunch/reload the app to retry with an internet connection up and running.';
        }
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(title),
                content: Text(content, style: Theme.of(context).textTheme.bodyMedium),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      }
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    myFocusNode.dispose();
    if (player != null) {
      player!.dispose();
    }
    super.dispose();
  }

  // dart Random.nextInt() can't handle int bigger than 2^32
  int _generateRandomBigInteger(int startInt, int maxInt) {
    final minLength = startInt.toString().length;
    final maxLength = maxInt.toString().length;
    final random = Random();

    if (minLength < 1 || maxLength < minLength) {
      throw ArgumentError('Invalid length parameters ($minLength, $maxLength)');
    }

    final randomLength = random.nextInt(maxLength - minLength + 1) + minLength;

    StringBuffer randomNumber;
    int rn;
    do {
      randomNumber = StringBuffer();
      randomNumber.write(random.nextInt(9) + 1);
      for (int i = 1; i < randomLength; i++) {
        randomNumber.write(random.nextInt(10));
      }
      rn = int.parse(randomNumber.toString());
    } while (rn < startInt || rn > maxInt);
    return rn;
  }

  int _generateRandomInteger(int startInt, int maxInt) {
    final minLength = startInt.toString().length;
    // if more than 9 digits or > 2^32, don't use dart Random()
    if (minLength > 9) {
      return _generateRandomBigInteger(startInt, maxInt);
    } else {
      return Random().nextInt(maxInt - startInt + 1) + startInt;
    }
  }

  void _generateNumbers(int length, int digits, bool allowNegative) {
    final random = Random();
    int startInt = pow(10, digits - 1).toInt();
    int maxInt = pow(10, digits).toInt() - 1;
    //debugPrint('startInt=$startInt, maxInt=$maxInt');
    numbers = [];
    int sum = 0, nextNum;
    for (int i = 0; i < length; i++) {
      nextNum = _generateRandomInteger(startInt, maxInt);
      if (allowNegative && sum > startInt) {
        bool isNegative = random.nextInt(2).toInt() == 1 ? true : false;
        if (isNegative) {
          nextNum = -1 * _generateRandomInteger(startInt, min(sum, maxInt));
        }
      }
      sum += nextNum;
      numbers.add(nextNum);
    }
    debugPrint(numbers.toString());
  }

  RichText currentOperation(List<int> op, bool showSum) {
    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.bodyLarge!;

    List<TextSpan> textSpans = [];
    int n;
    for (var i = 1; i < op.length; i++) {
      n = op[i];
      textSpans.add(TextSpan(
          text: n > 0 ? ' + ' : ' - ',
          style: textStyle.copyWith(fontWeight: FontWeight.bold, color: n > 0 ? Colors.grey[500] : Colors.grey[700])));
      textSpans.add(TextSpan(text: NumberFormat.decimalPattern(AppConfig.locale).format(n.abs()), style: textStyle));
    }
    if (showSum) {
      textSpans.add(TextSpan(text: ' = ', style: textStyle));
      final sum = op.fold<int>(0, (p, c) => p + c);
      textSpans.add(TextSpan(
          text: NumberFormat.decimalPattern(AppConfig.locale).format(sum),
          style: textStyle.copyWith(fontWeight: FontWeight.bold)));
    }
    final answerText = RichText(
        text: TextSpan(
      text: NumberFormat.decimalPattern(AppConfig.locale).format(op[0]),
      style: textStyle,
      children: textSpans,
    ));
    return answerText;
  }

  Future<void> _nextRandomNumber() async {
    if (!isPlaying) return;

    final numberModel = Provider.of<NumberModel>(context, listen: false);
    //debugPrint(_indx.toString());
    if (_indx == numbers.length) {
      if (player != null) {
        player!.stop();
      }
      setState(() {
        if (!AppConfig.useContinuousMode) {
          isPlaying = false;
        }
        isReplayable = true;
      });

      AppConfig.history.add((op: numbers, success: null));
      if (AppConfig.history.length > AppConfig.maxHistoryLength) {
        AppConfig.history.removeRange(0, AppConfig.history.length - AppConfig.maxHistoryLength);
      }

      Future.delayed(Duration(milliseconds: AppConfig.timeout), () {
        numberModel.setNumber('?');
        numberModel.setVisible(true);
        if (AppConfig.useContinuousMode) {
          setState(() {
            answerText = RichText(text: const TextSpan());
          });
        }
        if (!AppConfig.useContinuousMode) {
          textEditingController.clear();
          myFocusNode.requestFocus();
        }

        Future.delayed(Duration(milliseconds: 2 * AppConfig.timeout), () {
          if (AppConfig.useContinuousMode) {
            setState(() {
              answerText = currentOperation(numbers.sublist(0, _indx), true);
              isPlaying = true;
            });
            Future.delayed(Duration(milliseconds: AppConfig.timeout), () {
              // ignore: use_build_context_synchronously
              if (context.mounted) {
                _startPlay(context);
              }
            });
          }
        });
      });

      return;
    }
    final n = NumberFormat.decimalPattern(AppConfig.locale).format(numbers[_indx]);
    String nm = n;
    if (AppConfig.useNegNumber && _indx > 0 && numbers[_indx] > 0) {
      nm = '+$n';
    }
    numberModel.setNumber(nm);
    numberModel.setVisible(true);
    int timeFlash = AppConfig.timeFlash;
    if (AppConfig.useTTS && _hasMediaKitBeenInitialized && sounds.isNotEmpty) {
      final media = await Media.memory(sounds[_indx], type: 'audio/mpeg');
      if (player != null) {
        await player!.seek(const Duration(minutes: 0, seconds: 0, milliseconds: 0));
        await player!.open(media);
        final duration = MP3Processor.fromBytes(sounds[_indx]).duration.inMilliseconds;
        if (duration > timeFlash) {
          timeFlash = duration;
        }
      }
    }
    t1 = Timer(Duration(milliseconds: timeFlash), () async {
      numberModel.setVisible(false);
      _indx++;
      t2 = Timer(Duration(milliseconds: AppConfig.timeout), () async {
        await _nextRandomNumber();
      });
    });
  }

  void _replay() {
    _indx = 0;
    if (isPlaying) {
      _nextRandomNumber();
    }
  }

  Future<void> _getSounds(BuildContext context) async {
    var futures = <Future<File>>[];
    for (var i = 0; i < numbers.length; i++) {
      String n = numbers[i].abs().toString();
      if (AppConfig.useNegNumber) {
        if (i > 0) {
          if (numbers[i] > 0) {
            n = '\u002b $n';
          } else {
            n = '\u2212 $n';
          }
        }
      }
      n = Uri.encodeQueryComponent(n);
      final uri = '${AppConfig.host}/tools/tts?lang=${AppConfig.ttsLocale}&number=$n';
      futures.add(DefaultCacheManager().getSingleFile(uri, headers: {
        'User-Agent': AppConfig.userAgent,
        'X-Distinct-ID': AppConfig.distinctId
      }).timeout(const Duration(seconds: 5)));
    }
    try {
      var results = await Future.wait(futures, eagerError: true);
      for (var r in results) {
        sounds.add(r.readAsBytesSync());
      }
    } catch (e) {
      sounds.clear();
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: numbers.length * (AppConfig.timeFlash + AppConfig.timeout)),
          content: const Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('Error fetching some sound(s)'),
            SizedBox(width: 15),
            Icon(Icons.error, color: Colors.red)
          ])),
          showCloseIcon: true,
        ),
      );
    }
  }

  void _startPlay(BuildContext context) async {
    _indx = 0;
    textEditingController.clear();
    _generateNumbers(AppConfig.numRowInt, AppConfig.numDigit, AppConfig.useNegNumber);
    sounds.clear();
    if (_hasMediaKitBeenInitialized &&
        AppConfig.languages.isNotEmpty &&
        AppConfig.languages.contains(AppConfig.ttsLocale) &&
        AppConfig.useTTS) {
      await _getSounds(context);
    }
    setState(() {
      isReplayable = false;
    });
    if (context.mounted) {
      FocusScope.of(context).unfocus();
      Provider.of<NumberModel>(context, listen: false).setNumber('');
    }
    Future.delayed(Duration(milliseconds: AppConfig.timeout), () async {
      await _nextRandomNumber();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.bodyLarge!;
    final List<Widget> aboutBoxChildren = <Widget>[
      const SizedBox(height: 24),
      SizedBox(
          width: 550,
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(text: 'Flash Anzan', style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                TextSpan(text: ' is a ', style: textStyle),
                TextSpan(text: 'flutter', style: textStyle.copyWith(fontStyle: FontStyle.italic)),
                TextSpan(text: ' based GUI made to help you practice ', style: textStyle),
                TextSpan(text: 'anzan', style: textStyle.copyWith(fontStyle: FontStyle.italic)),
                TextSpan(text: ', i.e. mental calculation while visualising a ', style: textStyle),
                TextSpan(text: 'soroban', style: textStyle.copyWith(fontStyle: FontStyle.italic)),
                TextSpan(text: ' or an ', style: textStyle),
                TextSpan(text: 'abacus', style: textStyle.copyWith(fontStyle: FontStyle.italic)),
                TextSpan(
                    text:
                        '. You can also just practice mental calculation, or practice with a real soroban, if you like.\n\n'
                        'Check our website at ',
                    style: textStyle),
                TextSpan(
                    style: textStyle.copyWith(color: theme.colorScheme.primary),
                    text: 'https://www.sorobanexam.org',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        await launchUrl(Uri.parse('https://www.sorobanexam.org'));
                      }),
                TextSpan(style: textStyle, text: ' for more information and '),
                TextSpan(
                    text: 'exercices exam',
                    style: textStyle.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                TextSpan(text: ' to help you improve on using the soroban.', style: textStyle),
              ],
            ),
          )),
      const SizedBox(height: 24),
      SizedBox(
          width: 550,
          child: RichText(
              text: TextSpan(
                  text: GPL3,
                  style: textStyle.copyWith(fontFamily: 'NerdFont', fontSize: 12, fontWeight: FontWeight.w600)))),
    ];

    return Scaffold(
      appBar: AppBar(backgroundColor: lightBrown, foregroundColor: Colors.black, title: Text(widget.title), actions: [
        IconButton(
            onPressed: AppConfig.history.isEmpty
                ? null
                : () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HistoryRoute()));
                  },
            icon: const Icon(Icons.history)),
        IconButton(
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SettingsRoute(),
              ));
              await saveSettings(prefs);
            },
            icon: const Icon(Icons.settings))
      ]),
      drawer: Drawer(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: lightBrown),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Image.asset(
                      'assets/soroban-rounded-256x256.webp',
                      height: 64,
                      width: 64,
                    ),
                    const SizedBox(width: 15),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Flash Anzan',
                          style: TextStyle(
                              color: Colors.black, fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize)),
                      Text(AppConfig.appVersion,
                          style: TextStyle(
                              color: Colors.black, fontSize: Theme.of(context).textTheme.labelLarge!.fontSize))
                    ]),
                  ]),
                  const SizedBox(
                    height: 15,
                  ),
                  Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () async {
                          await launchUrl(Uri.parse('https://www.sorobanexam.org'));
                        },
                        child: const Text('www.sorobanexam.org', style: TextStyle(color: Colors.black)),
                      )),
                ]),
          ),
          Expanded(
              flex: 1,
              child: ListView(children: [
                ListTile(
                  enabled: AppConfig.history.isNotEmpty,
                  leading: const Icon(Icons.history),
                  title: const Text('History'),
                  onTap: () async {
                    Navigator.pop(context); // close the drawer, first
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HistoryRoute(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () async {
                    Navigator.pop(context); // close the drawer, first
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsRoute(),
                      ),
                    );
                  },
                ),
                AboutListTile(
                  icon: const Icon(Icons.info),
                  applicationIcon: Image.asset(
                    'assets/soroban-rounded-256x256.webp',
                    height: 64,
                    width: 64,
                  ),
                  applicationName: 'Flash Anzan',
                  applicationVersion: '${AppConfig.appVersion} (${AppConfig.commit}) [${AppConfig.platform}]',
                  applicationLegalese:
                      "Copyright © 2025\nsolsTiCe d'Hiver <solstice.dhiver@sorobanexam.org>\nGPL-3.0-or-later",
                  aboutBoxChildren: aboutBoxChildren,
                )
              ])),
        ],
      )),
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(
              top: 0.0,
              bottom: 32.0,
              left: 0.0,
              child: Container(margin: const EdgeInsets.all(16.0), child: answerText)),
          const Positioned.fill(child: MyDisplay()),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
          color: lightBrown,
          child: Row(spacing: 10.0, mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              iconSize: 32.0,
              icon: Icon(Icons.replay, color: isReplayable ? Colors.white : Colors.black),
              style: IconButton.styleFrom(
                  backgroundColor: green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
              onPressed: isReplayable
                  ? () {
                      setState(() {
                        isPlaying = true;
                      });
                      Provider.of<NumberModel>(context, listen: false).setVisible(false);
                      _replay();
                    }
                  : () {},
            ),
            SizedBox(
                width: 150,
                child: TextField(
                  focusNode: myFocusNode,
                  cursorColor: Colors.black,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black),
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                    labelText: 'Your answer',
                    labelStyle: TextStyle(color: Colors.black),
                    hintStyle: TextStyle(color: Colors.black),
                  ),
                )),
            IconButton(
              iconSize: 32.0,
              icon: Icon(Icons.input, color: isReplayable ? Colors.white : Colors.black),
              style: IconButton.styleFrom(
                  backgroundColor: green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
              onPressed: (isPlaying || _indx != AppConfig.numRowInt)
                  ? () {}
                  : () {
                      if (isPlaying) return;
                      final sum = numbers.fold<int>(0, (p, c) => p + c);
                      String msg;
                      Icon icon = const Icon(null);
                      try {
                        final sol = int.parse(textEditingController.text);
                        if (sol == sum) {
                          msg = 'The answer is correct';
                          icon = const Icon(Icons.check_box, color: Colors.green);
                          AppConfig.history[AppConfig.history.length - 1] =
                              (op: AppConfig.history[AppConfig.history.length - 1].op, success: true);
                        } else {
                          msg = 'The answer is incorrect';
                          icon = const Icon(Icons.close, color: Colors.red);
                          AppConfig.history[AppConfig.history.length - 1] =
                              (op: AppConfig.history[AppConfig.history.length - 1].op, success: false);
                        }
                        setState(() {
                          answerText = currentOperation(numbers.sublist(0, _indx), true);
                        });
                      } catch (e) {
                        msg = 'The answer is not a number';
                        icon = const Icon(Icons.error, color: Colors.red);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [Text(msg), const SizedBox(width: 15), icon])),
                          showCloseIcon: true,
                        ),
                      );
                    },
            ),
          ])),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: green,
        foregroundColor: Colors.white,
        onPressed: isPlayButtonDisabled
            ? () {}
            : () {
                setState(() {
                  isPlaying = !isPlaying;
                  answerText = RichText(text: const TextSpan());
                });
                if (!isPlaying) {
                  isPlayButtonDisabled = true;
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      isPlayButtonDisabled = false;
                    });
                  });
                  Provider.of<NumberModel>(context, listen: false).setVisible(false);
                  player?.stop();
                  t1?.cancel();
                  t2?.cancel();
                } else {
                  Provider.of<NumberModel>(context, listen: false).setVisible(false);
                  answerText = RichText(text: const TextSpan(text: ''));
                  _startPlay(context);
                }
              },
        child: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
      ),
    );
  }
}
