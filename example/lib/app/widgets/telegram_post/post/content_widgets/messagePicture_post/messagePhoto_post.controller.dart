import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service/td_api.dart' as tdapi;
import 'package:telegram_service_example/utils/mvc/MvcCommand.dart';
import 'dart:convert';
import 'dart:io' as io;

import 'load_messagePhoto_command.dart';

class MessagePhotoPostContentController extends MvcController {
  static const int IMAGE_READY_STATE = MvcController.NORMAL_STATE;
  static const int IMAGE_LOADING_STATE = MvcController.LOADING_STATE;
  static const int IMAGE_NOT_LOADED_STATE = -MvcController.LOADING_STATE;

  MvcCommand loadCommand;

  final TelegramChannelMessageInfo messsageInfo;
  void Function() onContentTap;

  Uint8List thumbnailBytes;
  int _photoSizeIndex = -1;

  tdapi.MessagePhoto get messageContent =>
      (messsageInfo.content as tdapi.MessagePhoto);

  tdapi.PhotoSize get messagePhotoObject => (_photoSizeIndex == -1)
      ? null
      : messageContent.photo.sizes[_photoSizeIndex];

  ImageProvider get messagePhotoFile => messagePhotoObject == null
      ? minithumbnail
      : FileImage(
          io.File(messagePhotoObject.photo.local.path),
        );

  MessagePhotoPostContentController(this.messsageInfo)
      : assert(messsageInfo.content is tdapi.MessagePhoto),
        super() {
    onContentTap = loadMessagePhoto;
    selectPhotoSize();
  }

  void selectPhotoSize() {
    if (_photoSizeIndex != -1) return;
    int screenWH = (Get.height + Get.width).round();
    _photoSizeIndex = messageContent.photo.sizes
        .indexWhere((element) => element.width + element.height >= screenWH);
    if (_photoSizeIndex == -1)
      _photoSizeIndex = messageContent.photo.sizes.length - 1;
  }

  String get postText => messageContent.caption.text;

  double get aspectRatio => picWidth / picHeight;

  double get picWidth =>
      messagePhotoObject?.width?.toDouble() ??
      messageContent.photo.minithumbnail.width.toDouble();
  double get picHeight =>
      messagePhotoObject?.height?.toDouble() ??
      messageContent.photo.minithumbnail.height.toDouble();

  MemoryImage get minithumbnail {
    if (thumbnailBytes == null) {
      final thumbnailData = messageContent.photo.minithumbnail.data;
      if (thumbnailData != null) thumbnailBytes = base64Decode(thumbnailData);
    }
    if (thumbnailBytes == null)
      return null;
    else
      return MemoryImage(thumbnailBytes);
  }

  void loadMessagePhoto() {
    if (loadCommand.canExecute) {
      Get.log('loadCommand for ${messsageInfo.id} started');
      loadCommand.execute();
    }
  }

  bool get isMessagePhotoDownloaded =>
      (messagePhotoObject?.photo?.local?.path?.isNotEmpty ?? false);

  @override
  void onInit() {
    super.onInit();

    loadCommand = LoadMessagePhotoCmd.cmd(messagePhotoObject);
/*       Worker _worker;
    _worker = ever(loadCommand, (_) {
      loadCommand.result.handleStatus(onCompleted: (_) {
        _worker.dispose();
        loadCommand.dispose();
      });
    }); */
  }

  @override
  void onReady() {
    super.onReady();
    if (isMessagePhotoDownloaded) {
      loadCommand.complete();
    } else {
      //     loadMessagePhoto();
    }
  }

  @override
  void dispose() {
    loadCommand.dispose();
    super.dispose();
  }
}
