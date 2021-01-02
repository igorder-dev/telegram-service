import 'dart:async';

import 'package:id_mvc_app_framework/utils/async/async_lock.dart';
import 'package:id_mvc_app_framework/utils/command/MvcCommand.dart';
import 'package:telegram_service_example/app/model/channel_info_store.dart';

import 'package:telegram_service_example/utils/telegram/handlers/telegram_chats_handler.dart';
import 'package:id_mvc_app_framework/framework.dart';

class LoadChannelsCmd {
  static MvcCommand cmd() => MvcCommand.async(
        canBeDoneOnce: true,
        func: (_) async {
          final channelsStore = TelegramChannelInfoStore();
          int _lastChannelsCount = 0;
          int _attempts = 0;

          while (!(((_lastChannelsCount == channelsStore.length &&
                  _lastChannelsCount > 0) ||
              _attempts++ > 5))) {
            Get.log(
                "[channels count] ${channelsStore.length} - attempts : $_attempts");
            _lastChannelsCount = channelsStore.length;
            await Future.delayed(1.seconds);

            await TdlibChatsHandler.instance.getAllChatsAsync();
          }
        },
      );
}
