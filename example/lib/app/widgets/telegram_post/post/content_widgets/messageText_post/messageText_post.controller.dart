import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service/tdapi.dart' as tdapi;

class MessageTextPostContentController extends MvcController {
  final TelegramChannelMessageInfo messsageInfo;
  tdapi.MessageText get messageContent =>
      (messsageInfo.content as tdapi.MessageText);

  MessageTextPostContentController(this.messsageInfo)
      : assert(messsageInfo.content is tdapi.MessageText);

  String get postText => messageContent.text.text;
}
