import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:id_mvc_app_framework/utils/command/MvcCommandBuilder.dart';
import 'package:telegram_service/tdapi.dart' as tdapi;
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service_example/app/widgets/telegram_post/post/content_widgets/collapsable_content/collapsable_content.view.dart';
import 'package:telegram_service_example/utils/telegram/posts_builders/post_content_widget.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
            c.onContentTap?.call();
          },
          child: Stack(
            children: [
              _visibilityDetector,
              MvcCommandBuilder(
                command: c.loadCommand,
                onReady: (_) =>
                    _mediaContentStateIconOverlay(_getNotReadyStateIcon()),
                onExecuting: (_) =>
                    _mediaContentStateIconOverlay(_getLoadingStateWidget()),
                onCompleted: (_) => Container(),
              ),
            ],
          ),
        ),
      );

  Widget get _visibilityDetector => VisibilityDetector(
        key: Key("${c.messsageInfo.id}"),
        child: _mediaContent,
        onVisibilityChanged: (VisibilityInfo info) {
          c.loadMessagePhoto();
        },
      );

  Widget get _mediaContent => AspectRatio(
        aspectRatio: c.aspectRatio,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: _mediaContentByState,
        ),
      );

  Widget _mediaContentStateIconOverlay(Widget icon) => AspectRatio(
        aspectRatio: c.aspectRatio,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            child: icon.paddingAll(5),
            decoration: BoxDecoration(
              color: Colors.grey[850].withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
      );

  Widget _getNotReadyStateIcon() => Icon(
        Icons.cloud_download_outlined,
        size: 40,
        color: Colors.grey[850],
      );
  Widget _getLoadingStateWidget() => SizedBox.fromSize(
        size: Size.square(40),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[850]),
        ),
      );

  Widget get _getMessagePhoto {
    return Image(
      image: c.messagePhotoFile,
      fit: BoxFit.none,
    );
  }

  Widget get _mediaContentByState {
    return MvcCommandBuilder(
      command: c.loadCommand,
      onCompleted: (_) => _getMessagePhoto,
      onExecuting: (_) => _getThumbnail,
      onReady: (_) => _getThumbnail,
    );
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
