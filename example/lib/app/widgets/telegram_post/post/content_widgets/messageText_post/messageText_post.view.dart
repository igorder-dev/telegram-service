import 'package:flutter/widgets.dart';
import 'package:telegram_service/tdapi.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service_example/app/widgets/telegram_post/post/content_widgets/collapsable_content/collapsable_content.view.dart';
import 'package:telegram_service_example/utils/telegram/posts_builders/post_content_widget.dart';

import 'messageText_post.controller.dart';

class MessageTextPostContent
    extends PostContentWidget<MessageTextPostContentController> {
  @mustCallSuper
  MessageTextPostContent({Key key, messageInfo})
      : super(key: key, messageInfo: messageInfo);

  @override
  MessageTextPostContentController initController() =>
      MessageTextPostContentController(messageInfo);

  @override
  Widget buildMain() => CollapsablePostContent(
        postText: c.postText,
        minLines: 30,
      );

  @override
  List<String> get contentTypes => [MessageText.CONSTRUCTOR];

  static PostContentWidget builder(TelegramChannelMessageInfo messageInfo) =>
      MessageTextPostContent(
        messageInfo: messageInfo,
      );
}
