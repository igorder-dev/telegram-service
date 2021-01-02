import 'package:get/get.dart';
import 'package:telegram_service/telegram_service.dart';
import 'package:telegram_service/tdapi.dart';
import 'package:telegram_service_example/app/screens/login_screen/login_screen.controller.dart';
import 'package:telegram_service_example/routes/routes.dart';

class TdlibLoginHandler extends TelegramEventHandler with GetxServiceMixin {
  @override
  List<String> get eventsToHandle => [UpdateAuthorizationState.CONSTRUCTOR];

  @override
  void onTelegramEvent(TdObject event, [String requestID]) {
    final _authState = event as UpdateAuthorizationState;
    Get.log("TdlibLoginHandler: ${_authState.authorizationState}");
    switch (_authState.authorizationState.getConstructor()) {
      case AuthorizationStateWaitPhoneNumber.CONSTRUCTOR:
        Get.offNamed(AppRoutes.LOGIN);
        return;
      case AuthorizationStateWaitCode.CONSTRUCTOR:
        Get.offNamed(AppRoutes.LOGIN);
        Get.find<LoginScreenController>().waitForCode = true;
        return;
      case AuthorizationStateReady.CONSTRUCTOR:
        Get.offAllNamed(AppRoutes.MAIN);
        return;
    }
  }

  void setAuthenticationPhoneNumber(String phone) {
    sendCommand(SetAuthenticationPhoneNumber(
      phoneNumber: phone,
      settings: PhoneNumberAuthenticationSettings(
        allowFlashCall: false,
        allowSmsRetrieverApi: false,
        isCurrentPhoneNumber: false,
      ),
    ));
  }

  void checkAuthenticationCode(
      String code, Function(CheckAuthResult result, String message) callback) {
    sendCommand(
      CheckAuthenticationCode(
        code: code,
      ),
      withCallBack: true,
      customCallback: (res, [id]) {
        switch (res.getConstructor()) {
          case Ok.CONSTRUCTOR:
            callback(CheckAuthResult.OK, null);
            return;
          case TdError.CONSTRUCTOR:
            callback(CheckAuthResult.ERROR, (res as TdError).message);
            return;
        }
      },
    );
  }
}

enum CheckAuthResult { OK, ERROR }
