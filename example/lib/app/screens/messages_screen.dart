import 'package:flutter/material.dart';
import 'package:telegram_service_example/app/widgets/app_scaffold.dart';
import 'package:telegram_service_example/app/widgets/messages_listview/messages_listview.view.dart';

class TelegramMessagesScreen extends StatelessWidget {
  final int channelId;
  final String title;

  const TelegramMessagesScreen({
    Key key,
    this.channelId,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title ?? "Channel Messages",
      body: TelegramMessagesList(
        channelId: channelId,
      ),
    );
  }
}
