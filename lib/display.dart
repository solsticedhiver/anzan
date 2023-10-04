import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  const MyDisplay({super.key, required this.style});

  final TextStyle style;

  @override
  State<MyDisplay> createState() => _MyDisplayState();
}

class _MyDisplayState extends State<MyDisplay> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NumberModel>(builder: (context, numberModel, child) {
      return Visibility(
          replacement: const SizedBox(height: 300),
          visible: numberModel.isVisible,
          child: Text(
            numberModel.number,
            style: widget.style,
          ));
    });
  }
}
