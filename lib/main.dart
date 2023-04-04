import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.brown,
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
  int _number = 0;
  int _indx = 0;
  Timer? _timer;
  bool isReplayable = false;
  bool isPlaying = false;
  bool isVisible = false;
  List<int> numbers = [];

  @override
  void initState() {
    super.initState();
  }

  void _generateNumbers(int length, int digits) {
    int startInt = pow(10, digits - 1).toInt();
    int maxInt = pow(10, digits).toInt() - startInt;
    debugPrint('maxInt=$maxInt, startInt=$startInt');
    numbers =
        List.generate(length, (index) => Random().nextInt(maxInt) + startInt);
    debugPrint(numbers.toString());
  }

  void _nextRandomNumber() {
    setState(() {
      isVisible = true;
      _number = numbers[_indx];
      _indx++;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isVisible = false;
        if (_indx >= numbers.length) {
          isPlaying = false;
          _timer!.cancel();
        }
      });
    });
  }

  void _replay() {
    _indx = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!isPlaying) {
        timer.cancel();
      } else {
        _nextRandomNumber();
      }
    });
  }

  void _startPlay() {
    _indx = 0;
    _generateNumbers(5, 2);
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!isPlaying) {
        timer.cancel();
      } else {
        _nextRandomNumber();
      }
    });
    setState(() {
      isReplayable = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.height / 2;
    TextSpan text = TextSpan(text: '99', style: TextStyle(fontSize: fontSize));
    TextPainter tp = TextPainter(text: text, textDirection: TextDirection.ltr);
    tp.layout();
    while (tp.width + 20 > MediaQuery.of(context).size.width) {
      fontSize -= 10;
      text = TextSpan(text: '99', style: TextStyle(fontSize: fontSize));
      tp = TextPainter(text: text, textDirection: TextDirection.ltr);
      tp.layout();
    }
    TextStyle style =
        TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold);
    double buttonSize = 48.0;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [
        IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SettingsRoute(),
              ));
            },
            icon: const Icon(Icons.settings))
      ]),
      /*
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
                            color: Colors.white,
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .fontSize)),
                  ]),
                  const SizedBox(
                    height: 15,
                  ),
                  const Expanded(
                      flex: 1,
                      child: Text(
                        'https://www.sorobanexam.org',
                        style: TextStyle(color: Colors.white),
                      )),
                ]),
          ),
          Expanded(
              flex: 1,
              child: ListView(children: [
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context); // close the drawer, first
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsRoute(),
                      ),
                    );
                  },
                ),
              ])),
        ],
      )),
      */
      body: Center(
        child: Stack(
          children: <Widget>[
            Visibility(
                replacement: const SizedBox(height: 300),
                visible: isVisible,
                child: Text(
                  '$_number',
                  style: style,
                )),
          ],
        ),
      ),
      bottomSheet: BottomSheet(
        backgroundColor: Colors.brown[100],
        builder: (context) {
          return Container(
              margin: const EdgeInsets.all(5),
              child: Row(children: [
                const Expanded(
                    child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Your answer',
                  ),
                )),
                const SizedBox(width: 8),
                ClipOval(
                    child: Container(
                        width: buttonSize,
                        height: buttonSize,
                        color: green,
                        child: IconButton(
                          color: Colors.white,
                          icon: const Icon(Icons.check),
                          onPressed: () {},
                        ))),
                const SizedBox(width: 8),
                ClipOval(
                    child: Container(
                        width: buttonSize,
                        height: buttonSize,
                        color: green,
                        child: IconButton(
                          color: Colors.white,
                          icon: const Icon(Icons.replay),
                          onPressed: isReplayable
                              ? () {
                                  setState(() {
                                    isPlaying = true;
                                  });
                                  _replay();
                                }
                              : null,
                        ))),
                const SizedBox(width: 8),
                ClipOval(
                    child: Container(
                        width: buttonSize,
                        height: buttonSize,
                        color: green,
                        child: IconButton(
                          color: Colors.white,
                          icon: isPlaying
                              ? const Icon(Icons.stop)
                              : const Icon(Icons.play_arrow),
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
                        ))),
              ]));
        },
        onClosing: () {},
      ),
    );
  }
}
