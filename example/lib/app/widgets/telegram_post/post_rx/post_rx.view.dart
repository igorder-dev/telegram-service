import 'package:flutter/widgets.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import '../post/post.view.dart';
import 'post_rx.controller.dart';

class TelegramPostRx extends MvcWidget<TelegramPostControllerRx> {
  final TelegramChannelMessageInfo messsageInfo;

  TelegramPostRx({
    Key key,
    this.messsageInfo,
  }) : super(key: key);

  @override
  TelegramPostControllerRx initController() =>
      TelegramPostControllerRx(messsageInfo);

  @override
  Widget buildMain() => TelegramPost(
        postText: c.postText,
        postTime: c.postTime,
        postTitle: c.postTitle,
        channelImage: c.channelImage,
      );
}
