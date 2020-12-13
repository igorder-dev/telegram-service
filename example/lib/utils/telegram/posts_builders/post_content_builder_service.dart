import 'package:flutter/widgets.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service_example/app/model/message_info.dart';

import 'post_content_widget.dart';

typedef T TelegramPostContentBuilder<T extends PostContentWidget>(
    TelegramChannelMessageInfo messageInfo);

class TelegramPostContentBuilderService with GetxServiceMixin {
  final Map<String, TelegramPostContentBuilder> buildersMap = Map();
  final TelegramPostContentBuilder defaultBuilder;

  TelegramPostContentBuilderService._(this.defaultBuilder);

  static void init(List<TelegramPostContentBuilder> builders,
      {TelegramPostContentBuilder defaultBuilder}) {
    final instance = TelegramPostContentBuilderService._(defaultBuilder);
    instance._initBuildersMap(builders);
    Get.put(instance);
  }

  void _initBuildersMap(List<TelegramPostContentBuilder> builders) {
    for (var builder in builders) {
      final contentTypes = builder(null).contentTypes;
      if (contentTypes == null) continue;
      contentTypes.forEach((type) {
        buildersMap[type] = builder;
      });
    }
  }

  static TelegramPostContentBuilderService get instance {
    try {
      TelegramPostContentBuilderService _instance = Get.find();
      return _instance;
    } catch (e) {
      throw ContentBuilderException(
          "Content builder service is not started. Please use [TelegramService.start] first.");
    }
  }

  static bool hasBuilder(TelegramChannelMessageInfo messageInfo) {
    final _instance = instance;
    final contentType = messageInfo.contentType;
    if (_instance.buildersMap.containsKey(contentType) ||
        _instance.defaultBuilder != null)
      return true;
    else
      return false;
  }

  static Widget build(TelegramChannelMessageInfo messageInfo) {
    final _instance = instance;
    final contentType = messageInfo.contentType;
    PostContentWidget result;
    try {
      if (_instance.buildersMap.containsKey(contentType)) {
        result = _instance.buildersMap[contentType](messageInfo);
      } else {
        if (_instance.defaultBuilder != null)
          result = _instance.defaultBuilder(messageInfo);
      }
      assert(result != null, "There is no content builder for $contentType");
    } catch (e, stackTrace) {
      result = _createErrorWidget(e, stackTrace);
    }
    return result;
  }

  static Widget _createErrorWidget(dynamic exception, StackTrace stackTrace) {
    final FlutterErrorDetails details = FlutterErrorDetails(
      exception: exception,
      stack: stackTrace,
      library: 'Telegram Content Builder',
      context: ErrorDescription('building'),
    );
    FlutterError.reportError(details);
    return ErrorWidget.builder(details);
  }
}

/// Custom Exception instance called in Telegram Service
class ContentBuilderException implements Exception {
  final _message;

  ContentBuilderException(this._message);

  String toString() {
    return "[Telegram Content Builder Error] $_message";
  }
}
