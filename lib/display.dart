import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import 'config.dart';

class NumberModel extends ChangeNotifier {
  String number = '';
  bool isVisible = false;

  void setNumber(String text) {
    number = text;
    notifyListeners();
  }

  void setVisible(bool visible) {
    isVisible = visible;
    notifyListeners();
  }
}

class MyDisplay extends StatefulWidget {
  const MyDisplay({super.key});

  @override
  State<MyDisplay> createState() => _MyDisplayState();
}

TextStyle _optimizeFontSize(BuildContext context, BoxConstraints constraints) {
  double fontSize = Theme.of(context).textTheme.displayLarge!.fontSize!;
  final testString = '9' * (AppConfig.numDigit + 1 + (AppConfig.numDigit / 3).round());
  TextSpan text = TextSpan(text: testString, style: TextStyle(fontSize: fontSize));
  TextPainter tp = TextPainter(text: text, textDirection: ui.TextDirection.ltr);
  tp.layout();
  while (tp.width + 20 < constraints.maxWidth && tp.height < constraints.maxHeight) {
    fontSize += 2;
    text = TextSpan(text: testString, style: TextStyle(fontSize: fontSize));
    tp = TextPainter(text: text, textDirection: ui.TextDirection.ltr);
    tp.layout();
  }
  //debugPrint(fontSize.toString());
  return TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold);
}

class _MyDisplayState extends State<MyDisplay> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NumberModel>(builder: (context, numberModel, child) {
      return Visibility(
          replacement: const SizedBox(height: 300),
          visible: numberModel.isVisible,
          child: LayoutBuilder(builder: (context, constraints) {
            final style = _optimizeFontSize(context, constraints);
            return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                  height: constraints.maxHeight,
                  alignment: Alignment.center,
                  child: Text(
                    textHeightBehavior:
                        const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
                    textAlign: TextAlign.center,
                    numberModel.number,
                    style: style,
                  )),
            ]);
          }));
    });
  }
}
