import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:telegram_service/tdapi.dart' as tdapi;
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service_example/app/widgets/telegram_post/post/content_widgets/messageMediaBase_post/messageMediaBase_post.view.dart';
import 'package:telegram_service_example/utils/telegram/posts_builders/post_content_widget.dart';
import 'package:id_mvc_app_framework/framework.dart';

import 'messageVideo_post.controller.dart';

import 'package:better_player/better_player.dart';

class MessageVideoPostContent
    extends MessageMediaBaseContentWidget<MessageVideoPostContentController> {
  @mustCallSuper
  MessageVideoPostContent({Key key, messageInfo})
      : super(key: key, messageInfo: messageInfo);

  @override
  MessageVideoPostContentController initController() =>
      MessageVideoPostContentController(messageInfo, initPlayerController);

  @override
  Widget get getNotReadyStateIcon => Icon(
        Icons.play_arrow,
        size: 40,
        color: Colors.grey[400],
      );

  @override
  Widget get getLoadingStateWidget {
    return Stack(
      children: [
        SizedBox.fromSize(
          size: Size.square(40),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[850]),
          ),
        ),
        SizedBox.fromSize(
          size: Size.square(40),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              "${c.downloadProgress}%",
              style: TextStyle(
                color: Colors.grey[850],
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget get getMediaContent => Stack(
        children: [
          BetterPlayer(
            controller: c.playerController,
          ),
          SizedBox.expand(
            child: Container(
              color: Colors.white.withOpacity(0.001),
              child: videoPlayerOverlay.paddingOnly(top: 40),
            ).paddingOnly(bottom: 40),
          ),
        ],
      );

  BetterPlayerController initPlayerController() {
    BetterPlayerControlsConfiguration controlsConfiguration =
        BetterPlayerControlsConfiguration(
      controlBarColor: Colors.grey[850].withOpacity(0.8),
      iconsColor: Colors.grey[400],
      progressBarPlayedColor: Colors.grey[400],
      progressBarHandleColor: Colors.grey[100],
      enableSkips: false,
      enableFullscreen: true,
      enableOverflowMenu: false,
      controlBarHeight: 40,
      loadingColor: Colors.red,
      showControlsOnInitialize: false,
    );
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
            aspectRatio: c.aspectRatio,
            autoPlay: false,
            fit: c.aspectRatio < 1 ? BoxFit.none : BoxFit.contain,
            autoDetectFullscreenDeviceOrientation: true,
            controlsConfiguration: controlsConfiguration,
            looping: true,
            eventListener: (event) {
              if (event.betterPlayerEventType ==
                  BetterPlayerEventType.changedPlayerVisibility) {
                if (!c.isMediaVisible) c.pauseVideo();
              }
            });
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.file, c.videoFIlePath);
    final _betterPlayerController = BetterPlayerController(
        betterPlayerConfiguration,
        betterPlayerDataSource: dataSource);
    return _betterPlayerController;
  }

  Widget get videoPlayerOverlay => !c.playerController.isPlaying()
      ? SizedBox.expand(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              child: getNotReadyStateIcon.paddingAll(5),
              decoration: BoxDecoration(
                color: Colors.grey[850].withOpacity(0.8),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
        )
      : Container();

  @override
  List<String> get contentTypes => [tdapi.MessageVideo.CONSTRUCTOR];

  static PostContentWidget builder(TelegramChannelMessageInfo messageInfo) =>
      MessageVideoPostContent(
        messageInfo: messageInfo,
      );
}
