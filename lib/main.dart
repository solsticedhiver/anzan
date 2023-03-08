import 'package:flutter/material.dart';
import 'dart:math';

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

  @override
  void initState() {
    _number = Random().nextInt(99);
    super.initState();
  }

  void _newRandomNumber() {
    setState(() {
      _number = Random().nextInt(99);
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(
        fontSize: MediaQuery.of(context).size.height / 2,
        fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
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
                  Image.asset(
                    'assets/soroban_logo_rounded.png',
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Expanded(
                      flex: 1, child: Text('https://www.sorobanexam.org')),
                ]),
          ),
          Expanded(
              flex: 1,
              child: ListView(children: const [
                ListTile(title: Text('Settings')),
              ])),
        ],
      )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_number',
              style: style,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newRandomNumber,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
