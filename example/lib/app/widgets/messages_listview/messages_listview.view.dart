import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service/td_api.dart' as tdapi;
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service_example/app/widgets/telegram_post/post/post.view.dart';
import 'package:telegram_service_example/app/widgets/telegram_post/post_rx/post_rx.view.dart';
import 'message_listview.controller.dart';

class TelegramMessagesList extends MvcWidget<TelegramMessagesListController> {
  final int channelId;

  TelegramMessagesList({
    Key key,
    @required this.channelId,
  }) : super(key: key);

  @override
  TelegramMessagesListController initController() =>
      TelegramMessagesListController(channelId: channelId);

  @override
  Widget buildMain() => Container(
        color: Colors.grey[300],
        child: ListView.builder(
          itemBuilder: messagesListItemBuilder,
          itemCount: c.messagesCount,
          cacheExtent: Get.mediaQuery.size.height *
              5, // setting up cach size equal to 5 screen for smoother scrolling
        ),
      );

  Widget messagesListItemBuilder(context, int index) {
    TelegramChannelMessageInfo message = c.messages[index];

    final postItem = TelegramPostRx(
      key: ObjectKey(message),
      messageInfo: message,
    );

    return Align(
      alignment: Alignment.topCenter,
      child: postItem.paddingOnly(bottom: 10.0),
    );
  }

  Widget messagesListSeperatorBuilder(context, int index) {
    return SizedBox(
      height: 15.0,
      width: 10,
      child: Container(
        color: Colors.grey[300],
      ),
    );
  }
}
