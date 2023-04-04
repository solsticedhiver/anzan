import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

const green = Color.fromARGB(255, 22, 131, 98);

class SettingsRoute extends StatelessWidget {
  const SettingsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SettingsList(sections: [
        SettingsSection(
            title: const Text('Numbers', style: TextStyle(color: green)),
            tiles: [
              SettingsTile(
                  leading: const Icon(Icons.numbers),
                  title: const Text('Digits'),
                  value: const Text('1')),
              SettingsTile(
                  leading: const Icon(Icons.table_rows),
                  title: const Text('Rows'),
                  value: const Text('5')),
            ]),
        SettingsSection(
            title: const Text('Timing', style: TextStyle(color: green)),
            tiles: [
              SettingsTile(
                  leading: const Icon(Icons.flash_on),
                  title: const Text('Flash'),
                  value: const Text('500')),
              SettingsTile(
                  leading: const Icon(Icons.timelapse),
                  title: const Text('Timeout'),
                  value: const Text('5')),
            ]),
        SettingsSection(
            title:
                const Text('Mode of operation', style: TextStyle(color: green)),
            tiles: [
              SettingsTile.switchTile(
                initialValue: false,
                leading: const Icon(Icons.exposure_minus_1),
                title: const Text('Subtraction'),
                onToggle: (value) {},
              ),
              SettingsTile.switchTile(
                leading: const Icon(Icons.voice_chat),
                title: const Text('TTS'),
                initialValue: false,
                onToggle: (value) {},
              ),
              SettingsTile.switchTile(
                leading: const Icon(Icons.waving_hand),
                title: const Text('Continuous mode'),
                initialValue: false,
                onToggle: (value) {},
              )
            ]),
      ]),
    );
  }
}
