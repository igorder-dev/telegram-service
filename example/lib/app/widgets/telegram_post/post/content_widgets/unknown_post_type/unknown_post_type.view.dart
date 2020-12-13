import 'package:flutter/widgets.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service_example/utils/telegram/posts_builders/post_content_widget.dart';

class UnknownPostContent extends PostContentWidget {
  @mustCallSuper
  UnknownPostContent({Key key, messageInfo})
      : super(key: key, messageInfo: messageInfo);

  @override
  Widget buildMain() => Text(messageInfo.content.getConstructor());

  @override
  List<String> get contentTypes => [];

  static PostContentWidget builder(TelegramChannelMessageInfo messageInfo) =>
      UnknownPostContent(
        messageInfo: messageInfo,
      );
}
