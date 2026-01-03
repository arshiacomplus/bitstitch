import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class DownloadManager {
  static const platform = MethodChannel('com.arshiaplus.bitstitch/media');
  static Future<void> refreshFileInSystem(String filePath) async {
    try {
      await platform.invokeMethod('refreshMedia', {'path': filePath});
      print("System Media Scanner Triggered!");
    } on PlatformException catch (e) {
      print("Failed to refresh media: ${e.message}");
    }
  }
  static Future<void> resumeDownload({
    required String url,
    required String filePath,
    required Function(double) onProgress,
  }) async {
    final originalFile = File(filePath);
    int existingSize = await originalFile.length();
    final String tempPartPath = "$filePath.part";
    final tempPartFile = File(tempPartPath);
    final request = http.Request('GET', Uri.parse(url));
    request.headers['Range'] = 'bytes=$existingSize-';
    final response = await http.Client().send(request);
    if (response.statusCode == 206) {
      int? totalBytesToDownload = response.contentLength;
      int downloadedBytes = 0;
      final sink = tempPartFile.openWrite();
      await response.stream.forEach((chunk) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        if (totalBytesToDownload != null) {
          onProgress(downloadedBytes / totalBytesToDownload);
        }
      });
      await sink.flush();
      await sink.close();
      final raf = await originalFile.open(mode: FileMode.append);
      await raf.writeFrom(await tempPartFile.readAsBytes());
      await raf.close();
      await tempPartFile.delete();
      String parentPath = originalFile.parent.path;
      String fileName = originalFile.path.split('/').last;
      String tempName = "$parentPath/temp_${DateTime.now().millisecondsSinceEpoch}_$fileName";
      final renamedFile = await originalFile.rename(tempName);
      await renamedFile.rename(filePath);
      print("Operation Completed Successfully!");
      await refreshFileInSystem(filePath);
    } else {
      throw Exception("Server does not support Resume (Code ${response.statusCode})");
    }
  }
}