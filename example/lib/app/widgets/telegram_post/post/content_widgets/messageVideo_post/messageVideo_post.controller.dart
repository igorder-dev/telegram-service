import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:id_mvc_app_framework/utils/command/MvcCommand.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service/tdapi.dart' as tdapi;
import 'package:telegram_service_example/app/widgets/telegram_post/post/content_widgets/messageMediaBase_post/messageMediaBase_post.controller.dart';
import 'dart:convert';

import 'package:better_player/better_player.dart';

import 'load_messageVideo.command.dart';

class MessageVideoPostContentController extends MessageMediaBaseController {
  MessageVideoPostContentController(
      TelegramChannelMessageInfo messsageInfo, this._initPlayerController)
      : assert(messsageInfo.content is tdapi.MessageVideo),
        super(
          messsageInfo,
          autoDownload: AutoDownload.no,
        );
  Uint8List thumbnailBytes;

  BetterPlayerController _playerController;
  BetterPlayerController get playerController =>
      _playerController ??= _initPlayerController();

  final BetterPlayerController Function() _initPlayerController;

  tdapi.MessageVideo get messageContent =>
      (messsageInfo.content as tdapi.MessageVideo);

  tdapi.Video get videoObject => messageContent.video;

  void onVideoLoading(tdapi.File file) {}

  int get videoFileSize => videoObject.video.expectedSize;
  int get videoDownloadedSize => videoObject.video.local.downloadedSize;
  int get downloadProgress =>
      ((videoDownloadedSize / videoFileSize) * 100).floor();
  String get videoFIlePath => videoObject.video.local.path;

  @override
  String get postText => messageContent.caption.text;

  @override
  MvcCommand createCommand() =>
      LoadMessageVideoCmd.cmd(videoObject, onVideoLoading);

  @override
  double get mediaHeight => videoObject.height.toDouble();

  @override
  double get mediaWidth => videoObject.width.toDouble();

  @override
  ImageProvider get thumbnail {
    if (thumbnailBytes == null) {
      final thumbnailData = messageContent.video.minithumbnail.data;
      if (thumbnailData != null) thumbnailBytes = base64Decode(thumbnailData);
    }
    if (thumbnailBytes == null)
      return AssetImage('assets/images/empty_thumbnail.jpg');
    else
      return MemoryImage(thumbnailBytes);
  }

  @override
  bool get isMediaDownloaded =>
      (videoObject.video?.local?.path?.isNotEmpty ?? false);

  @override
  void onContentTap() {
    if (!isMediaDownloaded) {
      super.loadMediaContent();
    } else {
      toggleVideoPlay();
    }
  }

  @override
  void onContectDoubleTap() {
    if (isMediaDownloaded) {
      playerController.toggleFullScreen();
    }
  }

  void toggleVideoPlay() {
    if (!playerController.isPlaying()) {
      playVideo();
    } else
      pauseVideo();
  }

  void playVideo() {
    playerController.play();
    playerController.setControlsVisibility(true);
    update();
  }

  void pauseVideo() {
    playerController.pause();
    update();
  }

  bool _wasDownloaded = false;

  @override
  void onInit() {
    super.onInit();
    Worker w;
    w = ever(loadCommand, (MvcCommandResult res) {
      res.handleStatus(
        onExecuting: (_) => _wasDownloaded = true,
        onCompleted: (_) {
          if (!playerController.isPlaying() && _wasDownloaded && isMediaVisible)
            playerController.play();
          w.dispose();
        },
      );
    });
  }
}
