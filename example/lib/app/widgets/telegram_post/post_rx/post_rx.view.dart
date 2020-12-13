import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service_example/utils/telegram/posts_builders/post_content_builder_service.dart';
import '../post/post.view.dart';
import 'post_rx.controller.dart';

class TelegramPostRx extends MvcWidget<TelegramPostControllerRx> {
  final TelegramChannelMessageInfo messageInfo;

  TelegramPostRx({
    Key key,
    this.messageInfo,
  }) : super(key: key);

  @override
  TelegramPostControllerRx initController() =>
      TelegramPostControllerRx(messageInfo);

  @override
  Widget buildMain() => TelegramPost(
        postContent: TelegramPostContentBuilderService.build(messageInfo),
        postTime: c.postTime,
        postTitle: c.postTitle,
        channelImage: c.channelImage,
        postViewsCount: messageInfo.viewsCount,
      );
}
