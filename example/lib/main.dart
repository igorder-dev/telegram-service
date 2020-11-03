import 'dart:io';

import 'package:flutter/material.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:id_mvc_app_framework/model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

import 'package:telegram_service/td_api.dart' show TdObject, TdlibParameters;
import 'package:telegram_service/telegram_service.dart';
import 'package:telegram_service_example/config/exceptions_config.dart';
import 'package:telegram_service_example/routes/routes.dart';

import 'utils/telegram/handlers/telegram_chats_handler.dart';
import 'utils/telegram/handlers/telegram_login_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  TelegramService.start(
    eventHandlers: [
      Get.put<TdlibLoginHandler>(TdlibLoginHandler()),
      Get.put<TdlibChatsHandler>(TdlibChatsHandler()),
    ],
    parameters: TdlibParameters(
      useTestDc: false,
      useSecretChats: false,
      useMessageDatabase: true,
      useFileDatabase: true,
      useChatInfoDatabase: true,
      ignoreFileNames: true,
      enableStorageOptimizer: true,
      systemLanguageCode: 'EN',
      applicationVersion: '0.0.1',
      deviceModel: 'Unknown',
      systemVersion: 'Unknonw',
      apiId: 1995291,
      apiHash: 'ea5fc6e2a611f9a00a0e3fd839c6d92f',
    ),
    onLogOut: () => Get.offAllNamed(AppRoutes.LOGOUT),
    onEvent: teleServiceEvent,
    logEnabled: true,
  );

  runMVCApp(
    exceptionsHandlingConfig: AppErrorConfig(),
    appSetup: MvcAppSettings(
      title: 'Sample mvc app',
      initialRoute: AppRoutes.INITIAL,
      getPages: AppRoutes.routes,
    ),
  );
}

void teleServiceEvent(TdObject event, [requestID]) async {
  final log =
      "event [${event.getConstructor()}]:\n ${JsonObject.fromJson(event.toJson()).toStringWithIndent()}\n\n";
//  Get.log(log);
  await writeToLogFile(log);
}

Future<void> writeToLogFile(String message) async {
  final directory = await getExternalStorageDirectory();
  final File _file = File('${directory.path}/telegram.log');
  bool isFileExists = await _file.exists();
  if (!isFileExists) _file.create(recursive: true);
  await _file.writeAsString(message, mode: FileMode.writeOnlyAppend);
}
