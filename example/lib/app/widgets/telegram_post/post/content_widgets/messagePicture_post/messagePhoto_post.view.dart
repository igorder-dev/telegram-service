import 'dart:ui';

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
        mediaContent: _postMediaContent1,
      );

  // TODO : Implement Post media content handling
  Widget get _postMediaContent => AspectRatio(
        aspectRatio: c.aspectRatio,
        child: Placeholder(
          color: Colors.yellow,
        ),
      );

  Widget get _postMediaContent1 => AspectRatio(
        aspectRatio: c.aspectRatio,
        child: FittedBox(
          child: Stack(
            children: [
              Container(
                width: c.picWidth,
                height: c.picHeight,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: c.minithumbnail,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Container(
                width: c.picWidth,
                height: c.picHeight,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          fit: BoxFit.fitWidth,
        ),
      );

  @override
  List<String> get contentTypes => [MessagePhoto.CONSTRUCTOR];

  static PostContentWidget builder(TelegramChannelMessageInfo messageInfo) =>
      MessagePhotoPostContent(
        messageInfo: messageInfo,
      );
}
