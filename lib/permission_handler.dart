import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissionHandler{

  Future<bool> cameraPermission() async {
    final PermissionStatus status = await Permission.camera.status;
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      final PermissionStatus result = await Permission.camera.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else if (result == PermissionStatus.limited) {
        return true;
      }else {
        debugPrint('Permission Denied!');
        return false;
      }
    }
  }

  Future<bool> galleryPermission() async {
    final PermissionStatus status = await Permission.storage.status;

    if (status == PermissionStatus.granted) {
      return true;
    } else {
      final PermissionStatus result = await Permission.storage.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else if (result == PermissionStatus.limited) {
        return true;
      }else {
        debugPrint('Permission Denied!');
        return false;
        return true;
      }
    }
  }

}