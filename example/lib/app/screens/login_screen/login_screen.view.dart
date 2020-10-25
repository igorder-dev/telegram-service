import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service_example/app/widgets/app_scaffold.dart';
import 'login_screen.controller.dart';

class LoginScreen extends MvcScreen<LoginScreenController> {
  @override
  LoginScreenController initController() => Get.put(LoginScreenController());

  @override
  Widget defaultScreenLayout(
      ScreenParameters screenParameters, LoginScreenController controller) {
    return AppScaffold(
      title: 'Login screen',
      body: controller.state == MvcController.LOADING_STATE &&
              !controller.waitForCode
          ? _loading
          : _body,
      floatingActionButton: _actionButton,
    );
  }

  Widget get _actionButton => controller.showActionButton
      ? FloatingActionButton(
          child: _actionButtonIcon,
          onPressed: !controller.waitForCode
              ? controller.submitPhoneNumber
              : controller.submitAuthCode,
        )
      : null;

  Widget get _actionButtonIcon {
    if (controller.state == MvcController.LOADING_STATE &&
        controller.waitForCode)
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    else if (controller.state != MvcController.LOADING_STATE &&
        controller.waitForCode)
      return Icon(Icons.check, size: 30.0);
    else
      return Icon(Icons.navigate_next, size: 30.0);
  }

  Widget get _body => Padding(
        padding: const EdgeInsets.all(20.0),
        child: AnimatedSwitcher(
          child: !controller.waitForCode
              ? _showPhoneEntry
              : (controller.state != MvcController.LOADING_STATE
                  ? _showCodeEntry
                  : _showPhoneEntry),
          duration: 1.seconds,
        ),
      );

  Widget get _showCodeEntry => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller.codeEntryController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter 5 digit code',
              hintText: '12345',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('${controller.codeLength}/5 symbols'),
              ),
            ),
          ),
          Expanded(
              child: Center(
            child: Text(
              'You should receive 5 digit code in you telegram client at +${controller.phoneNumberText}',
              style: Get.textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          )),
        ],
      );
  Widget get _showPhoneEntry => Container(
        height: double.infinity,
        child: TextField(
          controller: controller.phoneEntryController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter you phone number',
            prefixText: '+',
            hintText: '48 519478689',
          ),
        ),
      );

  Widget get _loading => Center(
        child: CircularProgressIndicator(),
      );
}
