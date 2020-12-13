import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:telegram_service/td_api.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service_example/app/widgets/telegram_post/post/content_widgets/collapsable_content/collapsable_content.view.dart';
import 'package:telegram_service_example/utils/telegram/posts_builders/post_content_widget.dart';

import 'messagePhoto_post.controller.dart';

class MessagePhotoPostContent
    extends PostContentWidget<MessagePhotoPostContentController> {
  @mustCallSuper
  MessagePhotoPostContent({Key key, messageInfo})
      : super(key: key, messageInfo: messageInfo);

  @override
  MessagePhotoPostContentController initController() =>
      MessagePhotoPostContentController(messageInfo);

  @override
  Widget buildMain() => CollapsablePostContent(
        postText: c.postText,
        mediaContent: _postMediaContent,
      );

  // TODO : Implement Post media content handling
  Widget get _postMediaContent => Placeholder(
        color: Colors.yellow,
      );

  @override
  List<String> get contentTypes => [MessagePhoto.CONSTRUCTOR];

  static PostContentWidget builder(TelegramChannelMessageInfo messageInfo) =>
      MessagePhotoPostContent(
        messageInfo: messageInfo,
      );
}
