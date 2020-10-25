import 'package:telegram_service/td_api.dart';

class TelegramChannelInfo {
  final int id;
  final String title;
  final ChatPhotoInfo photoInfo;

  TelegramChannelInfo.fromChat(Chat chat)
      : this.id = chat.id,
        this.title = chat.title,
        this.photoInfo = chat.photo;
}
