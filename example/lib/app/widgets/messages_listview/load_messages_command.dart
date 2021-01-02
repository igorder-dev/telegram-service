import 'dart:async';

import 'package:id_mvc_app_framework/utils/async/async_lock.dart';
import 'package:id_mvc_app_framework/utils/command/MvcCommand.dart';
import 'package:telegram_service_example/app/model/channel_info_store.dart';
import 'package:telegram_service_example/app/model/message_info_store.dart';

import 'package:telegram_service_example/utils/telegram/handlers/telegram_chats_handler.dart';
import 'package:id_mvc_app_framework/framework.dart';

class LoadMessagesCmd {
  static MvcCommand cmd(int channelId) =>
      MvcCommand<MvcCommandSingleParam<int>, void>.async(
        canBeDoneOnce: true,
        params: MvcCommandSingleParam(channelId),
        func: (param) async {
          // final asyncLock = AsyncLock();

          int _lastMessagesCount = 0;
          int _attempts = 0;

          final messagesStore = TelegramChannelMessageInfoStore();

          final cIdsList = _getChannelIdsList(param.value);
          while (!((_lastMessagesCount == messagesStore.length &&
                  _lastMessagesCount > 0) ||
              _attempts++ > 3)) {
            _lastMessagesCount = messagesStore.length;
            await _requestMessagesAsync(cIdsList);
          }
          // Timer.periodic(1.seconds, (timer) {
          //   if ((_lastMessagesCount == messagesStore.length &&
          //           _lastMessagesCount > 0) ||
          //       _attempts++ > 3) {
          //     timer.cancel();
          //     asyncLock.release();
          //     return;
          //   }
          //   _requestMessages(cIdsList);
          //   _lastMessagesCount = messagesStore.length;
          // });
          // return await asyncLock();
        },
      );

  static void _requestMessages(List<int> ids) => ids.forEach((chatId) {
        TdlibChatsHandler.instance.getChatMessages(chatId);
      });
  static Future<void> _requestMessagesAsync(List<int> ids) async {
    for (var chatId in ids) {
      await TdlibChatsHandler.instance.getChatMessagesAsync(chatId);
    }
  }

  static List<int> _getChannelIdsList(int channelId) {
    final channelsStore = TelegramChannelInfoStore();
    if (channelId != null && channelsStore.containsValue(channelId))
      return [channelId];
    else
      return channelsStore.keys.toList();
  }
}
