import 'package:flutter/cupertino.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:id_mvc_app_framework/utils/command/MvcCommand.dart';

import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:visibility_detector/visibility_detector.dart';

abstract class MessageMediaBaseController extends MvcController {
  MvcCommand _loadCommand;
  MvcCommand get loadCommand => _loadCommand ??= createCommand();

  final AutoDownload autoDownload;

  final TelegramChannelMessageInfo messsageInfo;

  MessageMediaBaseController(
    this.messsageInfo, {
    this.autoDownload = AutoDownload.onvisible,
  }) : super();
  double get aspectRatio => mediaWidth / mediaHeight;

  void loadMediaContent() {
    if (loadCommand.canExecute) {
      Get.log('loadCommand for ${messsageInfo.id} started');
      loadCommand.execute();
    }
  }

  bool _isMediaVisible = true;
  bool get isMediaVisible => _isMediaVisible;

  void loadContentWhenVisible(VisibilityInfo info) {
    _isMediaVisible = info.visibleFraction > 0;
    print("${messsageInfo.id} - visibility: $_isMediaVisible");
    if (autoDownload == AutoDownload.onvisible) loadMediaContent();
  }

  //* Abstract methods
  void onContentTap();

  void onContectDoubleTap() => null;

  String get postText;

  double get mediaWidth;
  double get mediaHeight;

  ImageProvider get thumbnail;
  bool get isMediaDownloaded;

  MvcCommand createCommand();

  @override
  void onReady() {
    super.onReady();
    if (isMediaDownloaded) {
      loadCommand.complete();
    } else if (autoDownload == AutoDownload.screen) {
      loadMediaContent();
    }
  }

  @override
  void dispose() {
    loadCommand.dispose();
    super.dispose();
  }
}

enum AutoDownload {
  no,
  screen,
  onvisible,
}
