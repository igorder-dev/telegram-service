import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service/td_api.dart' as tdapi;

class MessagePhotoPostContentController extends MvcController {
  final TelegramChannelMessageInfo messsageInfo;

  tdapi.MessagePhoto get messageContent =>
      (messsageInfo.content as tdapi.MessagePhoto);

  MessagePhotoPostContentController(this.messsageInfo)
      : assert(messsageInfo.content is tdapi.MessagePhoto);

  String get postText => messageContent.caption.text;

  double get aspectRatio =>
      messageContent.photo.minithumbnail.width /
      messageContent.photo.minithumbnail.height;
}
