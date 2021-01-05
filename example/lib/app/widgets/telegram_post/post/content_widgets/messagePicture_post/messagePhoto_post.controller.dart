import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:id_mvc_app_framework/utils/command/MvcCommand.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service/tdapi.dart' as tdapi;
import 'package:telegram_service_example/app/widgets/telegram_post/post/content_widgets/messageMediaBase_post/messageMediaBase_post.controller.dart';
import 'dart:convert';
import 'dart:io' as io;

import 'load_messagePhoto.command.dart';

class MessagePhotoPostContentController extends MessageMediaBaseController {
  MessagePhotoPostContentController(TelegramChannelMessageInfo messsageInfo)
      : assert(messsageInfo.content is tdapi.MessagePhoto),
        super(messsageInfo) {
    selectPhotoSize();
  }

  Uint8List thumbnailBytes;
  int _photoSizeIndex = -1;

  tdapi.MessagePhoto get messageContent =>
      (messsageInfo.content as tdapi.MessagePhoto);

  tdapi.PhotoSize get messagePhotoObject => (_photoSizeIndex == -1)
      ? null
      : messageContent.photo.sizes[_photoSizeIndex];

  ImageProvider get messagePhotoFile => messagePhotoObject == null
      ? thumbnail
      : FileImage(
          io.File(messagePhotoObject.photo.local.path),
        );

  void selectPhotoSize() {
    if (_photoSizeIndex != -1) return;
    int screenWH = (Get.height + Get.width).round();
    _photoSizeIndex = messageContent.photo.sizes
        .indexWhere((element) => element.width + element.height >= screenWH);
    if (_photoSizeIndex == -1)
      _photoSizeIndex = messageContent.photo.sizes.length - 1;
  }

  @override
  String get postText => messageContent.caption.text;

  @override
  MvcCommand createCommand() => LoadMessagePhotoCmd.cmd(messagePhotoObject);

  @override
  double get mediaHeight =>
      messagePhotoObject?.height?.toDouble() ??
      messageContent.photo.minithumbnail.height.toDouble();

  @override
  double get mediaWidth =>
      messagePhotoObject?.width?.toDouble() ??
      messageContent.photo.minithumbnail.width.toDouble();

  @override
  ImageProvider get thumbnail {
    if (thumbnailBytes == null) {
      final thumbnailData = messageContent.photo.minithumbnail.data;
      if (thumbnailData != null) thumbnailBytes = base64Decode(thumbnailData);
    }
    if (thumbnailBytes == null)
      return AssetImage('assets/images/empty_thumbnail.jpg');
    else
      return MemoryImage(thumbnailBytes);
  }

  @override
  bool get isMediaDownloaded =>
      (messagePhotoObject?.photo?.local?.path?.isNotEmpty ?? false);

  @override
  void onContentTap() {}
}
