import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:testify/widgets/custom_toast.dart';

class PermissionManager {
  /// Request storage permission only if it hasn't already been granted.
  Future<bool> checkAndRequestStoragePermission(BuildContext context) async {
    PermissionStatus status = await Permission.manageExternalStorage.status;
    if(!context.mounted) return false;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      PermissionStatus requestStatus = await Permission.manageExternalStorage.request();
      if(!context.mounted) return false;
      if (requestStatus.isGranted) {
        CustomToast.show(
          context: context,
          message: 'Storage permission granted after request',
        );
        return true;
      } else {
        CustomToast.show(
          context: context,
          message: 'Storage permission denied',
          isError: true,
        );
        return false;
      }
    } else if (status.isPermanentlyDenied) {
      // Permission is permanently denied, guide user to settings
      CustomToast.show(
        context: context,
        message: 'Storage permission permanently denied',
        isError: true,
      );
      await openAppSettings();
      return false;
    }
    return false;
  }
}
