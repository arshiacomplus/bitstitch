import 'dart:io';
class FilePatcher {
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }
  static Future<int> truncateFile(String filePath, int megabytesToRemove) async {
    final file = File(filePath);
    int currentLength = await file.length();
    int bytesToRemove = megabytesToRemove * 1024 * 1024;
    int newLength = currentLength > bytesToRemove ? currentLength - bytesToRemove : 0;
    final raf = await file.open(mode: FileMode.writeOnlyAppend);
    await raf.truncate(newLength);
    await raf.close();
    return newLength;
  }
  static Future<void> appendToFile(String mainFilePath, String partFilePath) async {
    final mainFile = File(mainFilePath);
    final partFile = File(partFilePath);
    if (await partFile.exists()) {
      final bytes = await partFile.readAsBytes();
      await mainFile.writeAsBytes(bytes, mode: FileMode.append);
      await partFile.delete();
    }
  }
}