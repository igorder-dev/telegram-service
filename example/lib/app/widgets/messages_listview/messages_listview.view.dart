import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service/td_api.dart' as tdapi;
import 'package:telegram_service_example/app/model/message_info.dart';
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
  Widget buildMain() => ListView.separated(
        itemBuilder: messagesListItemBuilder,
        separatorBuilder: messagesListSeperatorBuilder,
        itemCount: c.messagesCount,
      );

  Widget messagesListItemBuilder(context, int index) {
    TelegramChannelMessageInfo message = c.messages[index];

    String text = message.content is tdapi.MessageText
        ? (message.content as tdapi.MessageText).text.text
        : message.id.toString();
    return ListTile(
      title: Text('$text'),
      subtitle: Text(
        '${c.getChannelTitleById(message.channelId)}',
        style: Get.theme.textTheme.caption,
      ),
    );
  }

  Widget messagesListSeperatorBuilder(context, int index) {
    return Container(
      height: 15.0,
      width: double.infinity,
      color: Colors.grey[300],
    );
  }
}
