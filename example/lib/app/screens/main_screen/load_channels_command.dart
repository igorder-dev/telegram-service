import 'dart:async';

import 'package:telegram_service_example/app/model/channel_info_store.dart';
import 'package:telegram_service_example/utils/mvc/MvcCommand.dart';
import 'package:telegram_service_example/utils/mvc/async_lock.dart';
import 'package:telegram_service_example/utils/telegram/handlers/telegram_chats_handler.dart';
import 'package:id_mvc_app_framework/framework.dart';

class LoadChannelsCmd {
  static MvcCommand cmd() => MvcCommand.async(
        canBeDoneOnce: true,
        func: (_) async {
          final asyncLock = AsyncLock();

          final channelsStore = TelegramChannelInfoStore();
          int _lastChannelsCount = 0;
          int _attempts = 0;
          TdlibChatsHandler.instance.getAllChats();
          Timer.periodic(1.seconds, (timer) {
            if ((_lastChannelsCount == channelsStore.length &&
                    _lastChannelsCount > 0) ||
                _attempts++ > 5) {
              timer.cancel();
              asyncLock.release();
              return;
            }
            TdlibChatsHandler.instance.getAllChats();
            _lastChannelsCount = channelsStore.length;
          });

          return await asyncLock.lock;
        },
      );
}
