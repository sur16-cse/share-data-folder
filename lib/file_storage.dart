import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saf/saf.dart';

class FileStorage {
  static Future<bool> checkStoragePermission() async {
    PermissionStatus status;
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
      if ((info.version.sdkInt) <= 33) {
        status = await Permission.storage.request();
      } else {
        status = await Permission.manageExternalStorage.request();
      }
    } else {
      status = await Permission.storage.request();
    }

    switch (status) {
      case PermissionStatus.denied:
        return false;
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.restricted:
        return false;
      case PermissionStatus.limited:
        return true;
      case PermissionStatus.permanentlyDenied:
        return false;
      case PermissionStatus.provisional:
        return true;
    }
  }
  static Future<String> getExternalDocumentPath() async {
    bool  status =await checkStoragePermission();
    print(status);
    if (status!=true) {
      print (status);
      Directory _directory=await getApplicationDocumentsDirectory();
      print(_directory);
      await Saf(_directory.toString());
      await Saf.getDynamicDirectoryPermission(grantWritePermission: true);
        throw Exception('Permission denied');
    }

// Saf saf;
    Directory _directory;
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
      if ((info.version.sdkInt) <= 33){
        _directory =
            Directory("/storage/emulated/0/Android/data/com.example.shared_data");
      }else{
        _directory =
            Directory("/storage/emulated/0/Android/com.example.shared_data");
      }
      if (await _directory.exists()) {
        return _directory.path;
      } else {
        await _directory.create(recursive: true);
        return _directory.path;
      }
    } else {
      _directory = await getApplicationDocumentsDirectory();
    }

    final exPath = _directory.path;
    print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);
    return exPath;
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
