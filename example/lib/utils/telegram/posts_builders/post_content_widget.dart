import 'package:flutter/widgets.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service_example/app/model/message_info.dart';

abstract class PostContentWidget<T extends MvcController> extends MvcWidget<T> {
  final TelegramChannelMessageInfo messageInfo;

  @mustCallSuper
  PostContentWidget({Key key, this.messageInfo}) : super(key: key);

  List<String> get contentTypes;
}
