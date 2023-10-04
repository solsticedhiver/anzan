import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:anzan/display.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  runApp(ChangeNotifierProvider(
    create: (context) => NumberModel(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Map<int, Color> swatch = {
      50: Color(0xffffffff),
      100: Color(0xfffff0e6),
      200: Color(0xFFFFE1CD),
      300: Color(0xFFE6CBB8),
      400: Color(0xFFCCB4A4),
      500: lightBrown,
      600: Color(0xFF99877B),
      700: Color(0xFF807166),
      800: Color(0xFF665A52),
      900: Color(0xFF4D443D)
    };
    const primarySwatch = MaterialColor(0xFFB39E8F, swatch);

    return MaterialApp(
      title: 'Mental Calculation',
      theme: ThemeData(
        primarySwatch: primarySwatch,
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
  Timer? _timer;
  bool isReplayable = false;
  bool isPlaying = false;
  bool isVisible = false;
  List<int> numbers = [];
  List<List<int>> history = [];
  late TextStyle style;
  bool isExpanded = false;
  late MyDisplay myDisplay;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        final req = await http
            .get(Uri.parse('${AppConfig.host}/tools/tts?lang_list=1'));
        if (req.statusCode == 200) {
          for (var l in json.decode(req.body)) {
            AppConfig.languages.add(l);
          }
          //debugPrint(AppConfig.languages.toString());
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  void _generateNumbers(int length, int digits, bool allowNegative) {
    final random = Random();
    // dart Random.nextInt() can't handle int bigger than 2^32
    assert(digits <= 9);
    int startInt = pow(10, digits - 1).toInt();
    int maxInt = pow(10, digits).toInt() - startInt;
    int range = maxInt - startInt + 1;
    //debugPrint('startInt=$startInt, maxInt=$maxInt');
    numbers = [];
    int sum = 0;
    for (int i = 0; i < length; i++) {
      int nextNum = random.nextInt(range) + startInt;
      if (allowNegative && sum > startInt) {
        bool isNegative = random.nextInt(2).toInt() == 1 ? true : false;
        if (isNegative) {
          nextNum = -1 *
              (random.nextInt(min(sum - startInt, range)).toInt() + startInt);
        }
      }
      sum += nextNum;
      numbers.add(nextNum);
    }
    debugPrint(numbers.toString());
    AppConfig.history.add(numbers);
    if (AppConfig.history.length > AppConfig.maxHistoryLength) {
      AppConfig.history.removeRange(
          0, AppConfig.history.length - AppConfig.maxHistoryLength);
    }
  }

  void _nextRandomNumber() {
    NumberModel numberModel = Provider.of<NumberModel>(context, listen: false);
    numberModel.setNumber(numbers[_indx].toString());
    numberModel.setVisible(true);
    _indx++;
    Future.delayed(Duration(milliseconds: AppConfig.timeFlash), () {
      setState(() {
        numberModel.setVisible(false);
        if (_indx >= numbers.length) {
          isPlaying = false;
          _timer!.cancel();
          Future.delayed(Duration(milliseconds: AppConfig.timeout), () {
            setState(() {
              numberModel.setNumber('?');
              numberModel.setVisible(true);
            });
          });
          isReplayable = true;
          history.add(numbers);
        }
      });
    });
  }

  void _replay() {
    _indx = 0;
    _timer = Timer.periodic(Duration(milliseconds: AppConfig.timeout), (timer) {
      if (!isPlaying) {
        timer.cancel();
      } else {
        _nextRandomNumber();
      }
    });
  }

  void _startPlay() {
    _indx = 0;
    _generateNumbers(
        AppConfig.numRowInt, AppConfig.numDigit, AppConfig.useNegNumber);
    setState(() {
      Provider.of<NumberModel>(context, listen: false).setNumber('');
    });
    _timer = Timer.periodic(
        Duration(milliseconds: AppConfig.timeFlash + AppConfig.timeout),
        (timer) {
      if (!isPlaying) {
        timer.cancel();
      } else {
        _nextRandomNumber();
      }
    });
  }

  TextStyle _optimizeFontSize() {
    double fontSize = MediaQuery.of(context).size.height / 2;
    final testString = '9' * AppConfig.numDigit;
    TextSpan text =
        TextSpan(text: testString, style: TextStyle(fontSize: fontSize));
    TextPainter tp = TextPainter(text: text, textDirection: TextDirection.ltr);
    tp.layout();
    while (tp.width + 20 > MediaQuery.of(context).size.width) {
      fontSize -= 10;
      text = TextSpan(text: testString, style: TextStyle(fontSize: fontSize));
      tp = TextPainter(text: text, textDirection: TextDirection.ltr);
      tp.layout();
    }
    //debugPrint(fontSize.toString());
    return TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold);
  }

  @override
  Widget build(BuildContext context) {
    style = _optimizeFontSize();
    myDisplay = MyDisplay(style: style);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [
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
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
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
                            color: Colors.black,
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .fontSize)),
                  ]),
                  const SizedBox(
                    height: 15,
                  ),
                  Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () async {
                          await launchUrl(
                              Uri.parse('https://www.sorobanexam.org'));
                        },
                        child: const Text('www.sorobanexam.org',
                            style: TextStyle(color: Colors.black)),
                      )),
                ]),
          ),
          Expanded(
              flex: 1,
              child: ListView(children: [
                ExpansionPanelList(
                  children: [
                    ExpansionPanel(
                        isExpanded: isExpanded,
                        headerBuilder: (context, isExpanded) {
                          return const ListTile(
                            leading: const Icon(Icons.history),
                            title: const Text('History'),
                          );
                        },
                        body: SizedBox(
                            height: 200,
                            child: ListView.builder(
                                reverse: true,
                                itemCount: AppConfig.history.length,
                                itemBuilder: ((context, index) {
                                  StringBuffer operation = StringBuffer('');
                                  for (var n in AppConfig.history[index]) {
                                    operation.write(
                                        n > 0 ? ' + $n' : ' - ${n.abs()}');
                                  }
                                  return ListTile(
                                      title: Text(operation
                                          .toString()
                                          .replaceFirst(' + ', '')));
                                }))))
                  ],
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
              ])),
        ],
      )),
      body: Center(
        child: myDisplay,
      ),
      bottomSheet: BottomSheet(
        enableDrag: false,
        backgroundColor: lightBrown,
        builder: (context) {
          return Container(
              margin:
                  const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
              child: Row(children: [
                //const Expanded(child: SizedBox.shrink()),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(green),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(15)),
                  ),
                  onPressed: () {
                    setState(() {
                      isPlaying = !isPlaying;
                    });
                    if (!isPlaying && _timer != null) {
                      _timer!.cancel();
                      isVisible = false;
                    }
                    if (isPlaying) {
                      _startPlay();
                    }
                  },
                  child: Text(isPlaying ? 'Stop' : 'Play',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  style: ButtonStyle(
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(15)),
                      backgroundColor: MaterialStateProperty.all(
                          isReplayable ? green : Colors.grey[300])),
                  onPressed: isReplayable
                      ? () {
                          setState(() {
                            isPlaying = true;
                          });
                          _replay();
                        }
                      : () {},
                  child: Text('Replay',
                      style: TextStyle(
                          color: isReplayable ? Colors.white : Colors.black,
                          fontSize: 18)),
                ),
                const SizedBox(width: 15),
                const Expanded(
                    child: TextField(
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    labelText: 'Your answer',
                    labelStyle: TextStyle(color: Colors.black),
                    hintStyle: TextStyle(color: Colors.black),
                  ),
                )),
                const SizedBox(width: 15),
                ElevatedButton(
                  style: ButtonStyle(
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(15)),
                      backgroundColor: MaterialStateProperty.all(Colors.white)),
                  onPressed: () {},
                  child: const Text('Check',
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                ),
                //const Expanded(child: SizedBox.shrink()),
              ]));
        },
        onClosing: () {},
      ),
    );
  }
}
