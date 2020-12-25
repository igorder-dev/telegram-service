import 'dart:convert';

import 'package:id_mvc_app_framework/framework.dart';
import 'package:id_mvc_app_framework/model.dart';
import 'package:telegram_service/td_api.dart';
import 'package:telegram_service/telegram_service.dart';
import 'package:telegram_service_example/app/model/channel_info.dart';
import 'package:telegram_service_example/app/model/channel_info_store.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service_example/app/model/message_info_store.dart';
import 'package:telegram_service_example/utils/telegram/posts_builders/post_content_builder_service.dart';
import 'package:telegram_service_example/app/model/hive_storage_service.dart';

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

  void _handleMessagesEvent(Messages messages) async{
    final messagesStore = TelegramChannelMessageInfoStore();
    messages.messages.forEach((message) async {
      final messageInfo = TelegramChannelMessageInfo.fromMessage(message);
      if (TelegramPostContentBuilderService.hasBuilder(messageInfo)) {

        // Saving in Hive / restoring from Hive
        String messageKey = message.id.toString();

        // Getting the messages box and initializing it
        var storage = HiveStorageService<String>('messages');
        await storage.load();

        // Checking if message is already stored in the chats box
        if (storage.contains(messageKey)){
          // Adding to messagesStore from chats box
          messagesStore[message.id] = TelegramChannelMessageInfo.fromJson(jsonDecode(await storage.loadWithKey(messageKey)));
        }else{
          messagesStore[message.id] =
              TelegramChannelMessageInfo.fromMessage(message);
          storage.data= jsonEncode(TelegramChannelMessageInfo.fromMessage(message));
          await storage.saveWithKey(messageKey);

          Get.log("_handleMessagesEvent: Message ID${message.id} saved to Hive successfully");
        }

        // Closing the messages box
        storage.dispose();

        Get.log(
            "_handleMessagesEvent: [${message.chatId}] - [${message.id}] - [${message.content.getConstructor()} - added]");

        // serialization test
        //Get.log("JSON serialized message: ${TelegramChannelMessageInfo.fromMessage(message).toJson()}");



      } else {
        Get.log(
            "_handleMessagesEvent: [${message.chatId}] - [${message.id}] - [${message.content.getConstructor()} - excluded]");
      }
    });
  }

  void _handleChatEvent(Chat chat) async{
    if (chat.type.getConstructor() != ChatTypeSupergroup.CONSTRUCTOR) return;
    final channelsStore = TelegramChannelInfoStore();
    getChatMessages(chat.id);

    // serialization test
    // Get.log("JSON serialized channel: ${TelegramChannelInfo.fromChat(chat).toJson()}");

    // Saving in Hive / restoring from Hive
    String chatKey = chat.id.toString();

    // Getting the chats box and initializing it
    var storage = HiveStorageService<String>('chats');
    await storage.load();

    // Checking if chat is already stored in the chats box
    if (storage.contains(chatKey)){

      // Adding to channelsStore from chats box
      channelsStore[chat.id] = TelegramChannelInfo.fromJson(jsonDecode(await storage.loadWithKey(chatKey)));
      Get.log(
          "_handleMessagesEvent: Chat ID${chat.id} loaded from Hive successfully");
    }else {
      // Adding to channelsStore from chat
      channelsStore[chat.id] = TelegramChannelInfo.fromChat(chat);

      // Saving to chats box
      storage.data = jsonEncode(channelsStore[chat.id]);
      await storage.saveWithKey(chat.id.toString());
      Get.log(
          "_handleMessagesEvent: Chat ID${chat.id} saved to Hive successfully");
    }

    // Closing the chats box
    storage.dispose();
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
