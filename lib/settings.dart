import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import 'config.dart';

const green = Color(0xFF168362);
const lightBrown = Color(0xFFB39E8F);

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
      appBar: AppBar(title: const Text('Settings')),
      body: SettingsList(sections: [
        SettingsSection(
            title: const Text('Numbers', style: TextStyle(color: green)),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.numbers),
                title: const Text('Digits'),
                value: Text('$_numDigit'),
                onPressed: (context) async {
                  await showDialog<String>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(content:
                            StatefulBuilder(builder: (context, setState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Digits'),
                              Slider(
                                value: _numDigit.toDouble(),
                                label: _numDigit.toString(),
                                min: 1.0,
                                max: 10.0,
                                divisions: 10,
                                onChanged: (value) {
                                  setState(() {
                                    _numDigit = value.toInt();
                                  });
                                },
                              ),
                            ],
                          );
                        }));
                      });
                  setState(() {
                    AppConfig.numDigit = _numDigit;
                  });
                },
              ),
              SettingsTile(
                  leading: const Icon(Icons.table_rows),
                  title: const Text('Rows'),
                  value: Text('${AppConfig.numRowInt}')),
            ]),
        SettingsSection(
            title: const Text('Timing', style: TextStyle(color: green)),
            tiles: [
              SettingsTile(
                  leading: const Icon(Icons.flash_on),
                  title: const Text('Flash'),
                  value: Text('${AppConfig.timeFlash}')),
              SettingsTile(
                  leading: const Icon(Icons.timelapse),
                  title: const Text('Timeout'),
                  value: Text('${AppConfig.timeout}')),
            ]),
        SettingsSection(
            title:
                const Text('Mode of operation', style: TextStyle(color: green)),
            tiles: [
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
                description:
                    const Text('Continue without pause to enter answer'),
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
                        return AlertDialog(content:
                            StatefulBuilder(builder: (context, setState) {
                          return SingleChildScrollView(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: languages.map((l) {
                                    return ListTile(
                                        title: Text(l),
                                        leading: Radio<String>(
                                          value: l,
                                          groupValue: _ttsLocale,
                                          onChanged: (value) {
                                            setState(() {
                                              _ttsLocale = value!;
                                            });
                                          },
                                        ));
                                  }).toList()));
                        }));
                      });
                  setState(() {
                    AppConfig.ttsLocale = _ttsLocale;
                  });
                },
              ),
            ]),
      ]),
    );
  }
}
