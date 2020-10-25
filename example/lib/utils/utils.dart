import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:id_mvc_app_framework/framework.dart';

extension AppUtils on GetInterface {
  void errorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.redAccent,
      icon: Icon(Icons.error_outline),
    );
  }
}
