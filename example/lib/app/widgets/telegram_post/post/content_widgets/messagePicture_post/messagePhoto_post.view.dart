import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:telegram_service/tdapi.dart' as tdapi;
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service_example/app/widgets/telegram_post/post/content_widgets/messageMediaBase_post/messageMediaBase_post.view.dart';
import 'package:telegram_service_example/utils/telegram/posts_builders/post_content_widget.dart';

import 'messagePhoto_post.controller.dart';

class MessagePhotoPostContent
    extends MessageMediaBaseContentWidget<MessagePhotoPostContentController> {
  @mustCallSuper
  MessagePhotoPostContent({Key key, messageInfo})
      : super(key: key, messageInfo: messageInfo);

  @override
  MessagePhotoPostContentController initController() =>
      MessagePhotoPostContentController(messageInfo);

  @override
  Widget get getMediaContent => Image(
        image: c.messagePhotoFile,
        fit: BoxFit.fitWidth,
      );

  @override
  List<String> get contentTypes => [tdapi.MessagePhoto.CONSTRUCTOR];

  static PostContentWidget builder(TelegramChannelMessageInfo messageInfo) =>
      MessagePhotoPostContent(
        messageInfo: messageInfo,
      );
}
