import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  static Future<String> getExternalDocumentPath() async {

    Directory? _directory;
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
      if ((info.version.sdkInt) <= 33) {
        _directory =
            Directory("/storage/emulated/0/Android/data/com.example.shared_data");
      } else {
        _directory = await getExternalStorageDirectory();
      }


    if (_directory != null) {
      if (await _directory.exists()) {
        return _directory.path;
      } else {
        try {
          await _directory.create(recursive: true);
          return _directory.path;
        } catch (e) {
          throw Exception('Failed to create directory');
        }
      }
    } else {
      throw Exception('Failed to get directory');
    }
  }

  static Future<String> get _localPath async {
    final String directory = await getExternalDocumentPath();
    return directory;
  }

  static Future<File> writeCounter(String bytes, String name) async {
    final path = await _localPath;
    File file = File('$path/$name');
    print("Save file");
    return file.writeAsString(bytes);
  }
}
