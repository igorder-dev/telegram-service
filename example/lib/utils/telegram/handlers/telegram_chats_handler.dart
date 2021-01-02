import 'package:id_mvc_app_framework/framework.dart';
import 'package:id_mvc_app_framework/model.dart';

import 'package:telegram_service/telegram_service.dart';
import 'package:telegram_service/tdapi.dart';
import 'package:telegram_service_example/app/model/channel_info.dart';
import 'package:telegram_service_example/app/model/channel_info_store.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service_example/app/model/message_info_store.dart';
import 'package:telegram_service_example/utils/telegram/posts_builders/post_content_builder_service.dart';

class TdlibChatsHandler extends TelegramEventHandler with GetxServiceMixin {
  static TdlibChatsHandler get instance => Get.find();

  @override
  List<String> get eventsToHandle =>
      [Chats.CONSTRUCTOR, Chat.CONSTRUCTOR, Messages.CONSTRUCTOR];

  @override
  void onTelegramEvent(TdObject event, [String requestID]) {
    if (event == null) return;
    final log =
        "event [${event.getConstructor()}]:\n ${JsonObject.fromJson(event.toJson()).toStringWithIndent()}\n\n";
    //  Get.log("TdlibChatsHandler: $log");

    switch (event.getConstructor()) {
      case Chats.CONSTRUCTOR:
        _handleChatsEvent(event as Chats);
        return;
      case Chat.CONSTRUCTOR:
        _handleChatEvent(event as Chat);
        return;
      case Messages.CONSTRUCTOR:
        _handleMessagesEvent(event as Messages);
        return;
    }
  }

  final messagesStore = TelegramChannelMessageInfoStore();
  void _handleMessagesEvent(Messages messages) async {
    messagesStore.pureMap.addAll(_processMessages(messages));
    messagesStore.refresh();
  }

  Map<int, TelegramChannelMessageInfo> _processMessages(Messages messages) {
    final store = Map<int, TelegramChannelMessageInfo>();
    messages.messages.forEach((message) {
      final messageInfo = TelegramChannelMessageInfo.fromMessage(message);
      if (TelegramPostContentBuilderService.hasBuilder(messageInfo) &&
          !messagesStore.containsKey(message.id)) {
        store[message.id] = messageInfo;
        Get.log(
            "_handleMessagesEvent: [${message.chatId}] - [${message.id}] - [${message.content.getConstructor()} - added]");
      } else {
        Get.log(
            "_handleMessagesEvent: [${message.chatId}] - [${message.id}] - [${message.content.getConstructor()} - excluded]");
      }
    });
    return store;
  }

  void _handleChatEvent(Chat chat) {
    if (chat.type.getConstructor() != ChatTypeSupergroup.CONSTRUCTOR) return;
    final channelsStore = TelegramChannelInfoStore();

    channelsStore[chat.id] = TelegramChannelInfo.fromChat(chat);
  }

  void _handleChatsEvent(Chats chats) {
    chats.chatIds.forEach((id) {
      Get.log("_handleChatsEvent: $id");
      TelegramService.instance.sendCommand(
        GetChat(
          chatId: id,
        ),
      );
    });
  }

  void getChatMessages(int chatId) {
    TelegramService.instance.sendCommand(GetChatHistory(
      chatId: chatId,
      offset: -10,
      limit: 30,
      fromMessageId: 0,
    ));
  }

  Future<void> getChatMessagesAsync(int chatId) async {
    final messages =
        await TelegramService.instance.sendCommandWithResult(GetChatHistory(
      chatId: chatId,
      offset: -10,
      limit: 30,
      fromMessageId: 0,
    ));
    if (!(messages is Messages)) return;
    _handleMessagesEvent(messages);
  }

  void getAllChats() {
    TelegramService.instance.sendCommand(GetChats(
      chatList: ChatListMain(),
      limit: 100,
      offsetOrder: 9223372036854775807, //load chats from the beginning
    ));
  }

  Future<void> getAllChatsAsync() async {
    final chats = await TelegramService.instance.sendCommandWithResult(
      GetChats(
        chatList: ChatListMain(),
        limit: 100,
        offsetOrder: 9223372036854775807, //load chats from the beginning
      ),
    );
    if (!(chats is Chats)) return;
    for (var chatId in (chats as Chats).chatIds) {
      final chat = await TelegramService.instance.sendCommandWithResult(
        GetChat(
          chatId: chatId,
        ),
      );
      if (!(chat is Chat)) continue;
      _handleChatEvent(chat);
    }
  }
}
