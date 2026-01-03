import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _repoController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userController.text = prefs.getString('gh_user') ?? '';
      _repoController.text = prefs.getString('gh_repo') ?? '';
      _tokenController.text = prefs.getString('gh_token') ?? '';
    });
  }
  _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gh_user', _userController.text.trim());
    await prefs.setString('gh_repo', _repoController.text.trim());
    await prefs.setString('gh_token', _tokenController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Settings Saved!")));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GitHub Configuration")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _userController, decoration: const InputDecoration(labelText: "GitHub Username")),
            TextField(controller: _repoController, decoration: const InputDecoration(labelText: "Repo Name")),
            TextField(controller: _tokenController, decoration: const InputDecoration(labelText: "PAT Token"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveSettings, child: const Text("Save Settings")),
          ],
        ),
      ),
    );
  }
}