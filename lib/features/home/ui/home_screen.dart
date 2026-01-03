import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/file_patcher.dart';
import '../logic/download_manager.dart';
import '../../downloader/github_service.dart';
import '../../settings/settings_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  String? selectedFilePath;
  String? originalFileName;
  int fileSize = 0;
  final TextEditingController urlController = TextEditingController();
  double downloadProgress = 0;
  bool isDownloading = false;
  bool useGitHub = false;
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFilePath = result.files.single.path;
        originalFileName = result.files.single.name;
      });
      _updateFileSize();
    }
  }
  Future<void> _updateFileSize() async {
    if (selectedFilePath != null) {
      int size = await FilePatcher.getFileSize(selectedFilePath!);
      setState(() {
        fileSize = size;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BitStitch - File Fixer"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: isDownloading ? null : pickFile,
              icon: const Icon(Icons.file_open),
              label: const Text("Select Partial File"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
            ),
            const SizedBox(height: 20),
            if (selectedFilePath != null) ...[
              Card(
                color: Colors.blueGrey.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("File: $originalFileName",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                      const SizedBox(height: 8),
                      Text("Current Size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: isDownloading ? null : () async {
                  int newSize = await FilePatcher.truncateFile(selectedFilePath!, 5);
                  setState(() => fileSize = newSize);
                  showSuccess("5MB removed from file end.");
                },
                icon: const Icon(Icons.content_cut, color: Colors.redAccent),
                label: const Text("Truncate 5MB (Fix Corruption)", style: TextStyle(color: Colors.redAccent)),
              ),
            ],
            const Divider(height: 40),
            SwitchListTile(
              title: const Text("Use GitHub Action Mode"),
              subtitle: const Text("Use this if the server doesn't support Resume"),
              value: useGitHub,
              onChanged: (val) => setState(() => useGitHub = val),
              secondary: const Icon(Icons.auto_fix_high),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: urlController,
              enabled: !isDownloading,
              decoration: const InputDecoration(
                labelText: "Direct Download URL",
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (isDownloading && !useGitHub) ...[
              LinearProgressIndicator(value: downloadProgress),
              const SizedBox(height: 10),
              Text("Progress: ${(downloadProgress * 100).toStringAsFixed(1)}%", textAlign: TextAlign.center),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: isDownloading ? null : startOperation,
              style: ElevatedButton.styleFrom(
                backgroundColor: useGitHub ? Colors.purple : Colors.blueAccent,
                padding: const EdgeInsets.all(18),
              ),
              child: Text(
                isDownloading
                    ? "Processing..."
                    : (useGitHub ? "Trigger GitHub Action" : "Start Local Stitch"),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> startOperation() async {
    if (selectedFilePath == null || urlController.text.isEmpty) {
      showError("Please pick a file and enter a URL first!");
      return;
    }
    if (!(await Permission.manageExternalStorage.request().isGranted)) {
      showError("Storage Permission is required!");
      return;
    }
    setState(() => isDownloading = true);
    try {
  if (useGitHub) {
    bool success = await GitHubService.startAction(
      urlController.text, fileSize, originalFileName!
    );
    if (success) {
      showSuccess("Action started on GitHub. Waiting for server to cut the file...");
      bool completed = false;
      int attempts = 0;
      while (!completed && attempts < 30) {
        await Future.delayed(const Duration(seconds: 15));
        attempts++;
        String? artifactUrl = await GitHubService.getLatestArtifactUrl();
        if (artifactUrl != null) {
          setState(() => isDownloading = true);
          await GitHubService.downloadAndAppendArtifact(artifactUrl, selectedFilePath!);
          final String savePath = "/sdcard/Download/fixed_$originalFileName";
          await File(selectedFilePath!).copy(savePath);
          await DownloadManager.refreshFileInSystem(savePath);
          showSuccess("GitHub rescue completed! File saved to Downloads.");
          completed = true;
        }
      }
      if (!completed) showError("Timeout! GitHub server is taking too long.");
    }
  }
    } catch (e) {
      showError("Error: ${e.toString()}");
    } finally {
      setState(() => isDownloading = false);
      _updateFileSize();
    }
  }
  void showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  void showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
}