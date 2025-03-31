import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

import 'config.dart';

class SettingsRoute extends StatefulWidget {
  const SettingsRoute({super.key});

  @override
  State<SettingsRoute> createState() => _SettingsRouteState();
}

class _SettingsRouteState extends State<SettingsRoute> {
  String _ttsLocale = AppConfig.ttsLocale;
  int _numDigit = AppConfig.numDigit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: lightBrown, title: const Text('Settings')),
      body: Center(
          child: SettingsList(contentPadding: const EdgeInsets.only(left: 100, right: 100), sections: [
        SettingsSection(title: const Text('Numbers', style: TextStyle(color: green)), tiles: [
          CustomSettingsTile(
              child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
                    Container(margin: const EdgeInsets.only(left: 24, right: 24), child: const Icon(Icons.numbers)),
                    const Expanded(
                        flex: 2,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Digits',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                'at most for each number in the operation',
                              ),
                            ])),
                    const Expanded(child: SizedBox.shrink()),
                    Container(
                        width: 200,
                        child: SpinBox(
                          readOnly: true,
                          min: 1,
                          max: 9,
                          value: AppConfig.numDigit.toDouble(),
                          iconColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.grey;
                            }
                            if (states.contains(WidgetState.error)) {
                              return Colors.red;
                            }
                            if (states.contains(WidgetState.focused)) {
                              return Colors.blue;
                            }
                            return Colors.black;
                          }),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              AppConfig.numDigit = value.toInt();
                            });
                          },
                        ))
                  ]))),
          CustomSettingsTile(
              child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
                    Container(margin: const EdgeInsets.only(left: 24, right: 24), child: const Icon(Icons.table_rows)),
                    const Expanded(
                        flex: 2,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Rows',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                'length of the operation',
                              )
                            ])),
                    const Expanded(child: SizedBox.shrink()),
                    Container(
                        width: 200,
                        child: SpinBox(
                          readOnly: true,
                          min: 1,
                          max: 10,
                          value: AppConfig.numRowInt.toDouble(),
                          iconColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.grey;
                            }
                            if (states.contains(WidgetState.error)) {
                              return Colors.red;
                            }
                            if (states.contains(WidgetState.focused)) {
                              return Colors.blue;
                            }
                            return Colors.black;
                          }),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              AppConfig.numRowInt = value.toInt();
                            });
                          },
                        ))
                  ]))),
        ]),
        SettingsSection(title: const Text('Timing', style: TextStyle(color: green)), tiles: [
          CustomSettingsTile(
              child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
                    Container(margin: const EdgeInsets.only(left: 24, right: 24), child: const Icon(Icons.flash_on)),
                    const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        'Flash',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text('in ms')
                    ]),
                    const Expanded(child: SizedBox.shrink()),
                    Container(
                        width: 200,
                        child: SpinBox(
                          readOnly: true,
                          min: 50,
                          max: 1000,
                          step: 50,
                          pageStep: 100,
                          value: AppConfig.timeFlash.toDouble(),
                          iconColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.grey;
                            }
                            if (states.contains(WidgetState.error)) {
                              return Colors.red;
                            }
                            if (states.contains(WidgetState.focused)) {
                              return Colors.blue;
                            }
                            return Colors.black;
                          }),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              AppConfig.timeFlash = value.toInt();
                            });
                          },
                        ))
                  ]))),
          CustomSettingsTile(
              child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
                    Container(margin: const EdgeInsets.only(left: 24, right: 24), child: const Icon(Icons.timelapse)),
                    const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        'Timeout',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text('in ms')
                    ]),
                    const Expanded(child: SizedBox.shrink()),
                    Container(
                        width: 200,
                        child: SpinBox(
                          readOnly: true,
                          min: 100,
                          max: 5000,
                          step: 50,
                          pageStep: 100,
                          value: AppConfig.timeout.toDouble(),
                          iconColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.grey;
                            }
                            if (states.contains(WidgetState.error)) {
                              return Colors.red;
                            }
                            if (states.contains(WidgetState.focused)) {
                              return Colors.blue;
                            }
                            return Colors.black;
                          }),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              AppConfig.timeout = value.toInt();
                            });
                          },
                        ))
                  ]))),
        ]),
        SettingsSection(title: const Text('Mode of operation', style: TextStyle(color: green)), tiles: [
          SettingsTile.switchTile(
            initialValue: AppConfig.useNegNumber,
            activeSwitchColor: green,
            leading: const Icon(Icons.exposure_minus_1),
            title: const Text('Subtraction'),
            description: const Text('Allow negative numbers'),
            onToggle: (value) {
              setState(() {
                AppConfig.useNegNumber = value;
              });
            },
          ),
          SettingsTile.switchTile(
            leading: const Icon(Icons.waving_hand),
            title: const Text('Continuous mode'),
            description: const Text('Continue without pause to enter answer'),
            initialValue: AppConfig.useContinuousMode,
            activeSwitchColor: green,
            onToggle: (value) {
              setState(() {
                AppConfig.useContinuousMode = value;
              });
            },
          ),
          SettingsTile.navigation(
            leading: const Icon(Icons.voice_chat),
            title: const Text('TTS Voice '),
            value: Text(AppConfig.ttsLocale),
            onPressed: (context) async {
              final languages = ['No sound'] + AppConfig.languages;
              await showDialog<String>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(content: StatefulBuilder(builder: (context, setState) {
                      return SingleChildScrollView(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: languages.map((l) {
                                return RadioListTile(
                                  activeColor: green,
                                  selectedTileColor: green.withAlpha(31),
                                  selected: _ttsLocale == l,
                                  title: Text(l),
                                  value: l,
                                  groupValue: _ttsLocale,
                                  onChanged: (value) {
                                    setState(() {
                                      _ttsLocale = value!;
                                    });
                                  },
                                );
                              }).toList()));
                    }));
                  });
              setState(() {
                AppConfig.ttsLocale = _ttsLocale;
                AppConfig.locale = AppConfig.ttsLocale;
                if (AppConfig.locale == 'No sound') {
                  AppConfig.locale = 'en_US';
                }
              });
            },
          ),
        ]),
      ])),
    );
  }
}
