import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:id_mvc_app_framework/utils/command/MvcCommandBuilder.dart';
import 'package:telegram_service_example/app/widgets/telegram_post/post/content_widgets/collapsable_content/collapsable_content.view.dart';
import 'package:telegram_service_example/utils/telegram/posts_builders/post_content_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:id_mvc_app_framework/framework.dart';

import 'messageMediaBase_post.controller.dart';

abstract class MessageMediaBaseContentWidget<
    T extends MessageMediaBaseController> extends PostContentWidget<T> {
  @mustCallSuper
  MessageMediaBaseContentWidget({Key key, messageInfo})
      : super(key: key, messageInfo: messageInfo);

  @override
  Widget buildMain() => CollapsablePostContent(
        postText: c.postText,
        mediaContent: GestureDetector(
          onTap: c.onContentTap,
          onDoubleTap: c.onContectDoubleTap,
          child: Stack(
            children: [
              _visibilityDetector,
              MvcCommandBuilder(
                command: c.loadCommand,
                onReady: (_) =>
                    _mediaContentStateIconOverlay(getNotReadyStateIcon),
                onExecuting: (_) =>
                    _mediaContentStateIconOverlay(getLoadingStateWidget),
                onCompleted: (_) => Container(),
              ),
            ],
          ),
        ),
      );

  Widget get _visibilityDetector => VisibilityDetector(
        key: Key("${c.messsageInfo.id}"),
        child: _mediaContent,
        onVisibilityChanged: c.loadContentWhenVisible,
      );

  Widget get _mediaContent => AspectRatio(
        aspectRatio: c.aspectRatio,
        child: _mediaContentByState,
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

  Widget get getNotReadyStateIcon => Icon(
        Icons.cloud_download_outlined,
        size: 40,
        color: Colors.grey[850],
      );

  Widget get getLoadingStateWidget => SizedBox.fromSize(
        size: Size.square(40),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[850]),
        ),
      );

  Widget get getMediaContent;

  Widget get _mediaContentByState {
    return MvcCommandBuilder(
      command: c.loadCommand,
      onCompleted: (_) => getMediaContent,
      onExecuting: (_) => _getThumbnail,
      onReady: (_) => _getThumbnail,
    );
  }

  Widget get _getThumbnail => Stack(
        children: [
          Container(
            width: c.mediaWidth,
            height: c.mediaHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: c.thumbnail,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Container(
            width: c.mediaWidth,
            height: c.mediaHeight,
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
}
