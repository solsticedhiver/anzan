import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'config.dart';

class HistoryRoute extends StatefulWidget {
  const HistoryRoute({super.key});

  @override
  State<HistoryRoute> createState() => _HistoryRouteState();
}

class _HistoryRouteState extends State<HistoryRoute> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.bodyLarge!;

    return Scaffold(
        appBar: AppBar(backgroundColor: lightBrown, title: const Text('History')),
        body: Center(
            child: SizedBox(
                width: 500,
                child: ListView.builder(
                    itemCount: AppConfig.history.length,
                    itemBuilder: ((context, index) {
                      List<TextSpan> textSpans = [];
                      int n;
                      for (var i = 1; i < AppConfig.history[index].op.length; i++) {
                        n = AppConfig.history[index].op[i];
                        textSpans.add(TextSpan(
                            text: n > 0 ? ' + ' : ' - ',
                            style: textStyle.copyWith(
                                fontWeight: FontWeight.bold, color: n > 0 ? Colors.grey[500] : Colors.grey[700])));
                        textSpans.add(TextSpan(
                            text: NumberFormat.decimalPattern(AppConfig.locale).format(n.abs()), style: textStyle));
                      }
                      Icon icon = const Icon(null);
                      if (AppConfig.history[index].success != null) {
                        if (AppConfig.history[index].success!) {
                          icon = const Icon(Icons.check, color: Colors.green);
                        } else {
                          icon = const Icon(Icons.close, color: Colors.red);
                        }
                      }
                      return ListTile(
                        title: SelectableText.rich(TextSpan(
                          text: NumberFormat.decimalPattern(AppConfig.locale).format(AppConfig.history[index].op[0]),
                          style: textStyle,
                          children: textSpans,
                        )),
                        trailing: icon,
                      );
                    })))));
  }
}
