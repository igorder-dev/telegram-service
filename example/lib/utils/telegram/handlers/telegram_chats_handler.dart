import 'package:id_mvc_app_framework/framework.dart';
import 'package:id_mvc_app_framework/model.dart';
import 'package:telegram_service/src/tdapi/tdapi.dart';
import 'package:telegram_service/td_api.dart';
import 'package:telegram_service/telegram_service.dart';
import 'package:telegram_service/src/tdapi/tdapi.dart';
import 'package:telegram_service_example/app/model/channel_info.dart';
import 'package:telegram_service_example/app/model/channel_info_store.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service_example/app/model/message_info_store.dart';

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

  void _handleMessagesEvent(Messages messages) {
    final messagesStore = TelegramChannelMessageInfoStore();
    messages.messages.forEach((message) {
      Get.log(
          "_handleMessagesEvent: [${message.chatId}] - [${message.id}] - [${message.content.getConstructor()}]");
      messagesStore.add(
          message.id, TelegramChannelMessageInfo.fromMessage(message));
    });
  }

  void _handleChatEvent(Chat chat) {
    if (chat.type.getConstructor() != ChatTypeSupergroup.CONSTRUCTOR) return;
    final channelsStore = TelegramChannelInfoStore();
    getChatMessages(chat.id);
    channelsStore.add(chat.id, TelegramChannelInfo.fromChat(chat));
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

  void getAllChats() {
    TelegramService.instance.sendCommand(GetChats(
      chatList: ChatListMain(),
      limit: 100,
      offsetOrder: 9223372036854775807, //load chats from the beginning
    ));
  }
}
