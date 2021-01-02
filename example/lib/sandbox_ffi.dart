import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service/tdapi.dart';
import 'package:telegram_service/telegram_service.dart';

void main() async {
  final client = FFITdClient();
  client.create();
  Get.log("Setting client [$client]  verbosity level");
  client.executeSync(SetLogVerbosityLevel(
      newVerbosityLevel: 1)); //? call TdLib plugin to set verbosity level
}
