import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/archive.dart';
class GitHubService {
  static Future<bool> startAction(String fileUrl, int startByte, String fileName) async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('gh_user');
    final repo = prefs.getString('gh_repo');
    final token = prefs.getString('gh_token');
    if (user == null || token == null) return false;
    final apiUrl = 'https://api.github.com/repos/$user/$repo/actions/workflows/fixer.yml/dispatches';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      },
      body: jsonEncode({
        'ref': 'main',
        'inputs': {
          'url': fileUrl,
          'start_byte': startByte.toString(),
          'filename': fileName,
        }
      }),
    );
    return response.statusCode == 204;
  }
  static Future<String?> getLatestArtifactUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('gh_user');
    final repo = prefs.getString('gh_repo');
    final token = prefs.getString('gh_token');
    if (user == null || repo == null || token == null) return null;
    final runsUrl = 'https://api.github.com/repos/$user/$repo/actions/runs?status=completed&per_page=1';
    final response = await http.get(Uri.parse(runsUrl), headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github.v3+json',
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['workflow_runs'].isNotEmpty) {
        final runId = data['workflow_runs'][0]['id'];
        final artifactUrl = 'https://api.github.com/repos/$user/$repo/actions/runs/$runId/artifacts';
        final artRes = await http.get(Uri.parse(artifactUrl), headers: {
          'Authorization': 'Bearer $token',
        });
        if (artRes.statusCode == 200) {
          final artData = jsonDecode(artRes.body);
          if (artData['artifacts'].isNotEmpty) {
            return artData['artifacts'][0]['archive_download_url'];
          }
        }
      }
    }
    return null;
  }
  static Future<void> downloadAndAppendArtifact(String zipUrl, String targetFilePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('gh_token');
    final response = await http.get(Uri.parse(zipUrl), headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      for (final file in archive) {
        if (file.isFile) {
          final List<int> data = file.content;
          final targetFile = File(targetFilePath);
          await targetFile.writeAsBytes(data, mode: FileMode.append);
          print("Stitched artifact part to main file!");
        }
      }
    }
  }
}