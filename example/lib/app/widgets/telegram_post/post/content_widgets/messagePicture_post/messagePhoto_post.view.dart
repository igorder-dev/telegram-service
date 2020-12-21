import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:telegram_service/td_api.dart' as tdapi;
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service_example/app/widgets/telegram_post/post/content_widgets/collapsable_content/collapsable_content.view.dart';
import 'package:telegram_service_example/utils/telegram/posts_builders/post_content_widget.dart';
import 'package:id_mvc_app_framework/framework.dart';

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
        mediaContent: GestureDetector(
          onTap: () {
            // TODO : establish on tap media content onTap handling
            Get.log('${c.messsageInfo.id}');
          },
          child: Stack(
            children: [
              _mediaContent,
              _mediaContentStateIcon,
            ],
          ),
        ),
      );

  Widget get _mediaContent => AspectRatio(
        aspectRatio: c.aspectRatio,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: _mediaContentByState,
        ),
      );

  Widget get _mediaContentStateIcon => AspectRatio(
        aspectRatio: c.aspectRatio,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            child: Icon(
              Icons.cloud_download_outlined,
              size: 40,
              color: Colors.grey[850],
            ).paddingAll(5),
            decoration: BoxDecoration(
              color: Colors.grey[850].withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
      );

  // TODO : Implement Post media content handling
  Widget get _mediaPlaceholder => AspectRatio(
        aspectRatio: c.aspectRatio,
        child: Placeholder(
          color: Colors.yellow,
        ),
      );

  Widget get _mediaContentByState {
    switch (c.state) {
      case MessagePhotoPostContentController.IMAGE_NOT_LOADED_STATE:
        return _getThumbnail;
      default:
        return _mediaPlaceholder;
    }
  }

  Widget get _getThumbnail => Stack(
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
      );

  @override
  List<String> get contentTypes => [tdapi.MessagePhoto.CONSTRUCTOR];

  static PostContentWidget builder(TelegramChannelMessageInfo messageInfo) =>
      MessagePhotoPostContent(
        messageInfo: messageInfo,
      );
}
