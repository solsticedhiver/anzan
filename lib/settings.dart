import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'locale_web.dart' if (dart.library.io) 'locale_platform.dart';

class SettingsRoute extends StatefulWidget {
  const SettingsRoute({super.key});

  @override
  State<SettingsRoute> createState() => _SettingsRouteState();
}

class _SettingsRouteState extends State<SettingsRoute> {
  String _ttsLocale = AppConfig.ttsLocale;
  bool _useSystemTheme = AppConfig.themeMode == ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    final localGreen = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(foregroundColor: Colors.black, backgroundColor: lightBrown, title: const Text('Settings')),
      body: Center(
          child: SettingsList(sections: [
        SettingsSection(title: Text('Numbers', style: TextStyle(color: localGreen)), tiles: [
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
                    SizedBox(
                        width: 150,
                        child: SpinBox(
                          min: 1,
                          max: 13,
                          value: AppConfig.numDigit.toDouble(),
                          iconColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Theme.of(context).disabledColor;
                            }
                            if (states.contains(WidgetState.error)) {
                              return Colors.red;
                            }
                            if (states.contains(WidgetState.focused)) {
                              return Colors.blue;
                            }
                            return Theme.of(context).colorScheme.onSurface;
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
                    SizedBox(
                        width: 150,
                        child: SpinBox(
                          min: 1,
                          max: 15,
                          value: AppConfig.numRowInt.toDouble(),
                          iconColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Theme.of(context).disabledColor;
                            }
                            if (states.contains(WidgetState.error)) {
                              return Colors.red;
                            }
                            if (states.contains(WidgetState.focused)) {
                              return Colors.blue;
                            }
                            return Theme.of(context).colorScheme.onSurface;
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
        SettingsSection(title: Text('Timings', style: TextStyle(color: localGreen)), tiles: [
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
                    SizedBox(
                        width: 150,
                        child: SpinBox(
                          min: 50,
                          max: 1000,
                          step: 50,
                          pageStep: 100,
                          value: AppConfig.timeFlash.toDouble(),
                          iconColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Theme.of(context).disabledColor;
                            }
                            if (states.contains(WidgetState.error)) {
                              return Colors.red;
                            }
                            if (states.contains(WidgetState.focused)) {
                              return Colors.blue;
                            }
                            return Theme.of(context).colorScheme.onSurface;
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
                    SizedBox(
                        width: 150,
                        child: SpinBox(
                          min: 100,
                          max: 5000,
                          step: 50,
                          pageStep: 100,
                          value: AppConfig.timeout.toDouble(),
                          iconColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Theme.of(context).disabledColor;
                            }
                            if (states.contains(WidgetState.error)) {
                              return Colors.red;
                            }
                            if (states.contains(WidgetState.focused)) {
                              return Colors.blue;
                            }
                            return Theme.of(context).colorScheme.onSurface;
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
        SettingsSection(title: Text('Mode of operation', style: TextStyle(color: localGreen)), tiles: [
          SettingsTile.switchTile(
            initialValue: AppConfig.useNegNumber,
            activeSwitchColor: localGreen,
            leading: const Icon(Icons.exposure_minus_1),
            title: const Text('Subtraction'),
            description: const Text('Allow negative numbers'),
            onToggle: (value) {
              setState(() {
                debugPrint(value.toString());
                AppConfig.useNegNumber = value;
              });
            },
          ),
          SettingsTile.switchTile(
            initialValue: AppConfig.useContinuousMode,
            activeSwitchColor: localGreen,
            leading: const Icon(Icons.waving_hand),
            title: const Text('Continuous mode'),
            description: const Text('Continue (with a pause) without checking answer'),
            onToggle: (value) {
              setState(() {
                AppConfig.useContinuousMode = value;
              });
            },
          ),
          CustomSettingsTile(
              child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
                    Container(
                        margin: const EdgeInsets.only(left: 24, right: 24),
                        child: Icon(Icons.pause,
                            color: (AppConfig.useContinuousMode
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).disabledColor))),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        'Pause',
                        style: TextStyle(
                            fontSize: 20,
                            color: (AppConfig.useContinuousMode
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).disabledColor)),
                      ),
                      Text('in ms (between each operation)',
                          style: TextStyle(
                              color: (AppConfig.useContinuousMode
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).disabledColor)))
                    ]),
                    const Expanded(child: SizedBox.shrink()),
                    SizedBox(
                        width: 150,
                        child: SpinBox(
                          min: 500,
                          max: 10000,
                          step: 100,
                          pageStep: 100,
                          enabled: AppConfig.useContinuousMode,
                          value: AppConfig.pause.toDouble(),
                          iconColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Theme.of(context).disabledColor;
                            }
                            if (states.contains(WidgetState.error)) {
                              return Colors.red;
                            }
                            if (states.contains(WidgetState.focused)) {
                              return Colors.blue;
                            }
                            return Theme.of(context).colorScheme.onSurface;
                          }),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              AppConfig.pause = value.toInt();
                            });
                          },
                        ))
                  ]))),
        ]),
        SettingsSection(title: Text('Text To Speech', style: TextStyle(color: localGreen)), tiles: [
          SettingsTile.switchTile(
            enabled: AppConfig.languages.isNotEmpty,
            initialValue: AppConfig.useTTS,
            activeSwitchColor: localGreen,
            leading: const Icon(Icons.transcribe),
            title: const Text('TTS feature'),
            description: const Text('Get numbers voiced over'),
            onToggle: AppConfig.languages.isNotEmpty
                ? (value) {
                    setState(() {
                      AppConfig.useTTS = value;
                    });
                  }
                : null,
          ),
          SettingsTile.navigation(
            enabled: AppConfig.useTTS,
            leading: Icon(Icons.language,
                color: AppConfig.useTTS ? Theme.of(context).colorScheme.onSurface : Theme.of(context).disabledColor),
            title: Text('Language Voice',
                style: TextStyle(
                    color: AppConfig.useTTS
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).disabledColor)),
            value: Text(AppConfig.ttsLocale),
            onPressed: (context) async {
              final languages = AppConfig.languages;
              await showDialog<String>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: StatefulBuilder(builder: (context, setState) {
                        return SingleChildScrollView(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: languages.map((l) {
                                  return RadioListTile<String>(
                                    activeColor: localGreen,
                                    selectedTileColor: localGreen.withAlpha(31),
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
                      }),
                      actions: [
                        TextButton(
                            onPressed: () {
                              _ttsLocale = AppConfig.ttsLocale;
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK')),
                      ],
                    );
                  });
              setState(() {
                AppConfig.ttsLocale = _ttsLocale;
                AppConfig.locale = AppConfig.ttsLocale;
              });
            },
          ),
        ]),
        SettingsSection(title: Text('Theme', style: TextStyle(color: localGreen)), tiles: [
          SettingsTile.switchTile(
            initialValue: _useSystemTheme,
            activeSwitchColor: localGreen,
            leading: const Icon(Icons.palette),
            title: const Text('System Theme'),
            description: const Text('Follow the theme used by the system'),
            onToggle: (value) {
              ThemeMode tm = ThemeMode.system;
              if (!value) {
                tm = ThemeMode.light;
              }
              setState(() {
                _useSystemTheme = value;
                AppConfig.themeMode = tm;
              });
              Provider.of<ThemeModeModel>(context, listen: false).setThemeMode(tm);
            },
          ),
          SettingsTile.switchTile(
            enabled: !_useSystemTheme,
            initialValue: AppConfig.themeMode == ThemeMode.dark,
            activeSwitchColor: localGreen,
            leading: const Icon(Icons.dark_mode),
            title: Text('Dark Theme',
                style: TextStyle(
                    color:
                        _useSystemTheme ? Theme.of(context).disabledColor : Theme.of(context).colorScheme.onSurface)),
            description: const Text('Use the dark theme'),
            onToggle: !_useSystemTheme
                ? (value) {
                    ThemeMode tm = ThemeMode.dark;
                    if (!value) {
                      tm = ThemeMode.light;
                    }
                    Provider.of<ThemeModeModel>(context, listen: false).setThemeMode(tm);
                    setState(() {
                      AppConfig.themeMode = tm;
                    });
                  }
                : null,
          ),
        ]),
        SettingsSection(title: Text('Misc.', style: TextStyle(color: localGreen)), tiles: [
          SettingsTile(
              leading: const Icon(Icons.translate),
              description: const Text('Used when displaying numbers'),
              title: const Text('App locale'),
              value: Text(AppConfig.locale)),
          SettingsTile.switchTile(
            initialValue: AppConfig.isTelemetryAllowed,
            activeSwitchColor: localGreen,
            leading: const Icon(Icons.data_exploration),
            title: const Text('Telemetry'),
            description: const Text('Usage data collection'),
            onToggle: (value) {
              setState(() {
                AppConfig.isTelemetryAllowed = value;
              });
            },
          ),
        ])
      ])),
    );
  }
}
