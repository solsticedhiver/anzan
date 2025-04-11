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
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'config.dart';
import 'settings.dart';
import 'locale_web.dart' if (dart.library.io) 'locale_platform.dart';

bool _hasTTSWarningBeenShown = false;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  } else {
    AppConfig.host = 'http://127.0.0.1:5000';
  }

  AppConfig.locale = detectedSystemLocale;

  runApp(ChangeNotifierProvider(
    create: (context) => NumberModel(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Calculation',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(primary: green, secondary: lightBrown),
        //colorScheme: ColorScheme.fromSeed(seedColor: green),
      ),
      home: const MyHomePage(title: 'Anzan'),
    );
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
  bool isVisible = false;
  List<int> numbers = [];
  List<Uint8List> sounds = [];
  late TextStyle style;
  late MyDisplay myDisplay;
  final player = Player();
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        final req = await http.get(Uri.parse('${AppConfig.host}/tools/tts?lang_list=1'));
        if (req.statusCode == 200) {
          for (var l in json.decode(req.body)) {
            AppConfig.languages.add(l);
          }
          //debugPrint(AppConfig.languages.toString());
        }
      } catch (e) {
        debugPrint(e.toString());
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasTTSWarningBeenShown && AppConfig.languages.isEmpty) {
          _hasTTSWarningBeenShown = true;
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Error fetching the TTS languages list'),
                  content: const Text(
                    'There was a network error retrieving the language TTS list. TTS is disabled.\n'
                    'Relaunch/reload the app to retry.',
                  ),
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
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  // dart Random.nextInt() can't handle int bigger than 2^32
  String _generateRandomInteger(int minLength, int maxLength) {
    if (minLength < 1 || maxLength < minLength) {
      throw ArgumentError('Invalid length parameters');
    }

    final randomLength = Random().nextInt(maxLength - minLength + 1) + minLength;

    StringBuffer randomNumber = StringBuffer();
    randomNumber.write(Random().nextInt(9) + 1);
    for (int i = 1; i < randomLength; i++) {
      randomNumber.write(Random().nextInt(10));
    }

    return randomNumber.toString();
  }

  void _generateNumbers(int length, int digits, bool allowNegative) {
    final random = Random();
    bool isSizeTooBig = digits > 9; // or 2^32
    int startInt = pow(10, digits - 1).toInt();
    int maxInt = pow(10, digits).toInt() - startInt;
    int range = maxInt - startInt + 1;
    //debugPrint('startInt=$startInt, maxInt=$maxInt');
    numbers = [];
    int sum = 0, nextNum;
    for (int i = 0; i < length; i++) {
      if (isSizeTooBig) {
        nextNum = int.parse(_generateRandomInteger(startInt.toString().length, maxInt.toString().length));
      } else {
        nextNum = random.nextInt(range) + startInt;
      }
      if (allowNegative && sum > 0) {
        bool isNegative = random.nextInt(2).toInt() == 1 ? true : false;
        if (isNegative) {
          nextNum = -1 * (random.nextInt(min(sum - startInt, range)).toInt() + startInt);
        }
      }
      sum += nextNum;
      numbers.add(nextNum);
    }
    debugPrint(numbers.toString());
  }

  Future<void> _nextRandomNumber() async {
    if (!isPlaying) return;

    final numberModel = Provider.of<NumberModel>(context, listen: false);
    //debugPrint(_indx.toString());
    if (_indx >= numbers.length) {
      player.stop();
      textEditingController.clear();
      setState(() {
        isPlaying = false;
      });
      Future.delayed(Duration(milliseconds: AppConfig.timeout), () {
        setState(() {
          numberModel.setNumber('?');
          numberModel.setVisible(true);
        });
      });
      isReplayable = true;
      AppConfig.history.add(numbers);
      AppConfig.success.add(null);
      if (AppConfig.history.length > AppConfig.maxHistoryLength) {
        AppConfig.history.removeRange(0, AppConfig.history.length - AppConfig.maxHistoryLength);
        AppConfig.success.removeRange(0, AppConfig.history.length - AppConfig.maxHistoryLength);
      }
      return;
    }
    numberModel.setNumber(NumberFormat.decimalPattern(AppConfig.locale).format(numbers[_indx]));
    numberModel.setVisible(true);
    if (sounds.isNotEmpty) {
      final media = await Media.memory(sounds[_indx], type: 'audio/mpeg');
      await player.seek(const Duration(minutes: 0, seconds: 0, milliseconds: 0));
      await player.open(media);
      await Future.delayed(Duration(milliseconds: AppConfig.timeFlash), () async {
        numberModel.setVisible(false);
        _indx++;
        await Future.delayed(Duration(milliseconds: AppConfig.timeout), () async {
          await _nextRandomNumber();
        });
      });
    } else {
      //debugPrint('no sound');
      Future.delayed(Duration(milliseconds: AppConfig.timeFlash), () async {
        numberModel.setVisible(false);
        _indx++;
        Future.delayed(Duration(milliseconds: AppConfig.timeout), () async {
          await _nextRandomNumber();
        });
      });
    }
  }

  void _replay() {
    _indx = 0;
    if (isPlaying) {
      _nextRandomNumber();
    }
  }

  Future<void> _getSounds() async {
    http.Response req;
    sounds.clear();
    for (var i = 0; i < numbers.length; i++) {
      final n = numbers[i];
      final uri = '${AppConfig.host}/tools/tts?lang=${AppConfig.ttsLocale}&number=$n';
      req = await http.get(Uri.parse(uri));
      if (req.statusCode == 200) {
        sounds.add(req.bodyBytes);
      }
    }
  }

  void _startPlay() async {
    _indx = 0;
    textEditingController.clear();
    _generateNumbers(AppConfig.numRowInt, AppConfig.numDigit, AppConfig.useNegNumber);
    if (AppConfig.languages.contains(AppConfig.ttsLocale)) {
      await _getSounds();
    } else {
      sounds.clear();
    }
    if (context.mounted) {
      Provider.of<NumberModel>(context, listen: false).setNumber('');
    }
    await _nextRandomNumber();
  }

  TextStyle _optimizeFontSize() {
    double fontSize = MediaQuery.of(context).size.height / 2;
    final testString = '9' * (AppConfig.numDigit + 2);
    TextSpan text = TextSpan(text: testString, style: TextStyle(fontSize: fontSize));
    TextPainter tp = TextPainter(text: text, textDirection: ui.TextDirection.ltr);
    tp.layout();
    while (tp.width + 20 > MediaQuery.of(context).size.width) {
      fontSize -= 10;
      text = TextSpan(text: testString, style: TextStyle(fontSize: fontSize));
      tp = TextPainter(text: text, textDirection: ui.TextDirection.ltr);
      tp.layout();
    }
    //debugPrint(fontSize.toString());
    return TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold);
  }

  @override
  Widget build(BuildContext context) {
    style = _optimizeFontSize();
    myDisplay = MyDisplay(style: style);

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
                TextSpan(text: ', a.k.a mental calculation while visualising a ', style: textStyle),
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
      appBar: AppBar(backgroundColor: lightBrown, title: Text(widget.title), actions: [
        IconButton(
            onPressed: AppConfig.history.isEmpty
                ? null
                : () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HistoryRoute()));
                  },
            icon: const Icon(Icons.history)),
        IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SettingsRoute(),
              ));
              setState(() {
                style = _optimizeFontSize();
              });
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
                      'assets/soroban_logo_rounded.png',
                      height: 64,
                      width: 64,
                    ),
                    const SizedBox(width: 15),
                    Text('Flash Anzan',
                        style: TextStyle(
                            color: Colors.black, fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize)),
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
                    setState(() {
                      style = _optimizeFontSize();
                    });
                  },
                ),
                AboutListTile(
                  icon: const Icon(Icons.info),
                  applicationIcon: Image.asset(
                    'assets/soroban_logo_rounded.png',
                    height: 64,
                    width: 64,
                  ),
                  applicationName: 'Flash Anzan',
                  applicationVersion: AppVersion,
                  applicationLegalese:
                      "Copyright © 2025\nsolsTiCe d'Hiver <solstice.dhiver@sorobanexam.org>\nGPL-3.0-or-later",
                  aboutBoxChildren: aboutBoxChildren,
                )
              ])),
        ],
      )),
      body: Center(
        child: myDisplay,
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
                width: 200,
                child: TextField(
                  cursorColor: Colors.black,
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
              onPressed: () {
                if (isPlaying) return;
                var sum = numbers.fold<int>(0, (p, c) => p + c);
                String msg;
                Icon icon = const Icon(null);
                try {
                  final sol = int.parse(textEditingController.text);
                  if (sol == sum) {
                    msg = 'The answer is correct';
                    icon = const Icon(Icons.check_box_rounded, color: Colors.green);
                    AppConfig.success[AppConfig.history.length - 1] = true;
                  } else {
                    msg = 'The answer is incorrect';
                    icon = const Icon(Icons.close, color: Colors.red);
                    AppConfig.success[AppConfig.history.length - 1] = false;
                  }
                } catch (e) {
                  msg = 'The answer is not a number';
                  icon = const Icon(Icons.error, color: Colors.red);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(
                        child: Row(
                            mainAxisSize: MainAxisSize.min, children: [Text(msg), const SizedBox(width: 15), icon])),
                    showCloseIcon: true,
                  ),
                );
              },
            ),
          ])),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        //backgroundColor: green,
        //foregroundColor: Colors.white,
        onPressed: () {
          setState(() {
            isPlaying = !isPlaying;
          });
          if (!isPlaying) {
            isVisible = false;
            isReplayable = true;
            player.stop();
          } else {
            Provider.of<NumberModel>(context, listen: false).setVisible(false);
            _startPlay();
          }
        },
        child: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
      ),
    );
  }
}
