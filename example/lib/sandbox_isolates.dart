import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:id_mvc_app_framework/framework.dart';

import 'package:telegram_service/tdapi.dart';
import 'package:telegram_service/telegram_service.dart';
import 'package:telegram_service_example/app/model/channel_info_store.dart';

import 'app/model/channel_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsoServiceRunner.start(runFFIClient, onError: (e) {
    print("[Isolate Error] $e");
  });
  IsoServiceRunner.dataIn().listen(onData);
}

void runFFIClient(IsoServicePortal portal) async {
    final client = FFITdClient();
  client.create();
  Get.log("Setting client [$client]  verbosity level");
  client.executeSync(SetLogVerbosityLevel(
      newVerbosityLevel: 1)); //? call TdLib plugin to set verbosity level
}

void runService(IsoServicePortal portal) async {
  portal.init();
  await TelegramService.start(
    eventHandlers: [],
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
    onEvent: teleServiceEvent,
    logEnabled: false,
  );
}

void runTask(IsoServicePortal portal) {
  portal.init();
  IsoServiceRunner.dataIn().listen(onData);
  for (var i = 0; i < 100000; i++) {
    Future.delayed(1.seconds, () {
      print("creating object $i");
      IsoServiceRunner.send(createChannelnfo(i));
    });
  }
}

dynamic createChannelnfo(int i) {
  final channelsStore = TelegramChannelInfoStore();
  int id = Random().nextInt(10000);
  channelsStore[i] =
      TelegramChannelInfo(i, "test channel $id", Rx(ChatPhotoInfo()));
  return channelsStore[i].toJson();
}

void onData(dynamic data) async {
  switch (IsoServiceRunner.isInIsolateZone()) {
    case true:
      print("[Print from Isolate] $data");
      break;
    case false:
      print("[Print from Main] $data");
      await Future.delayed(
        Random().nextInt(2).seconds,
        () => IsoServiceRunner.send(Random().nextInt(10000)),
      );
      break;
  }
}

void teleServiceEvent(TdObject event, [requestID]) async {
  final log = "event [${event.getConstructor()}]:\n ${event.toJson()}\n\n";
  Get.log(log);
  //await writeToLogFile(log);
}
