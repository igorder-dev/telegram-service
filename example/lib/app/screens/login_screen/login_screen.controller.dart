import 'dart:async';

import 'package:flutter/material.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service_example/routes/routes.dart';
import 'package:telegram_service_example/utils/telegram/handlers/telegram_login_handler.dart';
import 'package:telegram_service_example/utils/utils.dart';

class LoginScreenController extends MvcController {
  bool _showCode = false;
  bool get waitForCode => _showCode;
  set waitForCode(bool value) {
    _showCode = value;
    isLoading = false;
  }

  bool showActionButton = false;
  bool get enableActionButton => codeEntryController.text.length == 5;
  int get codeLength => codeEntryController.text.length;
  String get phoneNumberText => phoneEntryController.text ?? '';

  final TextEditingController phoneEntryController = TextEditingController();
  final TextEditingController codeEntryController = TextEditingController();

  void submitPhoneNumber() {
    TdlibLoginHandler loginHandler = Get.find();
    final phoneNumber = "+${phoneEntryController.text}";
    if (loginHandler == null) return;
    if (!phoneNumber.isPhoneNumber)
      throw FormatException("Wrong phone number format!", phoneNumber);
    loginHandler.setAuthenticationPhoneNumber(phoneNumber);
    _showCode = true;
    isLoading = true;
  }

  void submitAuthCode() {
    if (enableActionButton && codeEntryController.text.isNum) {
      TdlibLoginHandler loginHandler = Get.find();
      Get.log("AuthCode: ${codeEntryController.text}");
      if (loginHandler == null) return;
      _showCode = false;
      isLoading = true;

      loginHandler.checkAuthenticationCode(
        codeEntryController.text,
        submitAuthCodeCallBack,
      );
    } else {
      Get.errorSnackbar(
        "Wrong auth code",
        "Auth code must be 5 digits long.",
      );
    }
  }

  void submitAuthCodeCallBack(CheckAuthResult res, String message) {
    switch (res) {
      case CheckAuthResult.ERROR:
        codeEntryController.text = "";
        _showCode = true;
        isLoading = false;
        Get.errorSnackbar(
          "Authentication error",
          message,
        );
        return;
      case CheckAuthResult.OK:
        Get.offNamed(AppRoutes.INITIAL);
        return;
    }
  }

  void onActionButtonPress() {
    _showCode = !_showCode;
    isLoading = true;
    Timer(3.seconds, () {
      isLoading = false;
    });
  }

  @override
  void onInit() {
    isLoading = true;
    Timer(2.seconds, () {
      isLoading = false;
    });
    phoneEntryController.addListener(() {
      showActionButton = phoneEntryController.text.isNotEmpty;
      update();
    });

    codeEntryController.addListener(() {
      update();
    });
  }

  @override
  void onClose() {
    phoneEntryController.dispose();
    codeEntryController.dispose();
  }
}
