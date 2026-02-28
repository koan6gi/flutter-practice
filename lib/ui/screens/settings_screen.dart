import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.translate('settings')),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(settings.translate('darkMode')),
            value: settings.isDarkMode,
            onChanged: (value) {
              settings.toggleTheme(value);
            },
          ),
          const Divider(),
          ListTile(
            title: Text(settings.translate('language')),
            trailing: DropdownButton<String>(
              value: settings.languageCode,
              items: const [
                DropdownMenuItem(value: 'ru', child: Text('Русский')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  settings.changeLanguage(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
