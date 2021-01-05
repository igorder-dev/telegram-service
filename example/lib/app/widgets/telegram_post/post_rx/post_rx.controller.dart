import 'package:flutter/painting.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service/tdapi.dart' as tdapi;

class TelegramPostControllerRx extends MvcController {
  final TelegramChannelMessageInfo messsageInfo;
  TelegramPostControllerRx(this.messsageInfo);

  String get postText => messsageInfo.content is tdapi.MessageText
      ? (messsageInfo.content as tdapi.MessageText).text.text
      : messsageInfo.content.getConstructor();

  String get postTime => messsageInfo.messageTimeFormatted;

  String get postTitle => messsageInfo.channel?.title ?? "...";

  FileImage get channelImage => messsageInfo.channel.channelPhoto;

  Worker _worker;

  @override
  void onInit() {
    //
    super.onInit();
    _worker = ever(messsageInfo.channel.photoInfoRx, (_) {
      if (messsageInfo.channel.isChannelPhotoDownloaded) _worker.dispose();
      update();
    });
  }
}
