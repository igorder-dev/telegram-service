import 'package:flutter/painting.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:telegram_service/tdapi.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'dart:io' as io;

import 'package:telegram_service_example/utils/telegram/handlers/telegram_file_download_handler.dart';

part 'channel_info.g.dart';

@JsonSerializable()
class TelegramChannelInfo {
  final int id;
  final String title;

  @RxChatPhotoInfoSerializer()
  final Rx<ChatPhotoInfo> photoInfoRx;
  bool _isChannelPhotoDownloading = false;

  FileImage get channelPhoto {
    if (isChannelPhotoDownloaded) {
      return FileImage(
        io.File(photoInfoRx.value.small.local.path),
      );
    } else {
      if (!isChannelPhotoDownloading) {
        _downloadChannelPhoto();
      }
      return null;
    }
  }

  void downloadChannelPhoto() {
    if (_checkChannelPhotoDownloaded()) {
      _downloadChannelPhoto();
    }
  }

  void _downloadChannelPhoto() {
    if (photoInfoRx.value?.small == null) return;
    _isChannelPhotoDownloading = true;
    TdlibFileDownloadHandler.instance.downloadFile(
      photoInfoRx.value.small,
      (file, path) {
        _isChannelPhotoDownloading = false;
        _updatePhotoInfo(file);
      },
      onFileDownloading: _updatePhotoInfo,
    );
  }

  void _updatePhotoInfo(File file) => photoInfoRx.update((photoInfo) {
        photoInfo.small = file;
      });

  bool _checkChannelPhotoDownloaded() =>
      (photoInfoRx.value.small?.local?.path?.isNotEmpty ?? false);

  bool get isChannelPhotoDownloading => _isChannelPhotoDownloading;

  bool get isChannelPhotoDownloaded => _checkChannelPhotoDownloaded();

  TelegramChannelInfo.fromChat(Chat chat)
      : this.id = chat.id,
        this.title = chat.title,
        this.photoInfoRx = chat.photo.obs;

  // Default constructor for build_runner to work
  TelegramChannelInfo(this.id, this.title, this.photoInfoRx);

  // JSON serialization/deserialization
  factory TelegramChannelInfo.fromJson(Map<String, dynamic> json) =>
      _$TelegramChannelInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TelegramChannelInfoToJson(this);
}

class RxChatPhotoInfoSerializer
    implements JsonConverter<Rx<ChatPhotoInfo>, Map<String, dynamic>> {
  const RxChatPhotoInfoSerializer();

  @override
  Rx<ChatPhotoInfo> fromJson(Map<String, dynamic> json) =>
      Rx(ChatPhotoInfo.fromJson(json));

  @override
  Map<String, dynamic> toJson(Rx<ChatPhotoInfo> chatPhotoInfo) =>
      chatPhotoInfo.toJson();
}
