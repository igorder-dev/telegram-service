import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:id_mvc_app_framework/utils/command/MvcCommandBuilder.dart';
import 'package:telegram_service_example/app/model/channel_info.dart';

import 'package:telegram_service_example/app/widgets/app_scaffold.dart';
import 'package:telegram_service_example/app/widgets/messages_listview/messages_listview.view.dart';

import 'main_screen.controller.dart';

class MainScreen extends MvcScreen<MainScreenController> {
  @override
  MainScreenController initController() => MainScreenController();

  @override
  Widget defaultScreenLayout(
      ScreenParameters screenParameters, MainScreenController controller) {
    return _tabsLayout;
  }

  Widget get _tabsLayout => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppScaffold().title),
            bottom: TabBar(
              tabs: [
                Text('Channels'),
                Text('Messages'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _body,
              TelegramMessagesList(
                channelId: null,
              ),
            ],
          ),
        ),
      );

  Widget get _body => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: MvcCommandBuilder(
            command: c.channelsLoadCmd,
            onCompleted: (_) => _channelsListView,
            onReady: (_) => Center(
              child: Text(
                'TeleFeed!',
                style: Theme.of(Get.context).textTheme.headline2,
              ),
            ),
            onExecuting: (_) => _loadingView,
          )),
        ],
      );

  Widget get _loadingView => Align(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );

  Widget get _channelsListView => ListView.builder(
        itemBuilder: channelListItemBuilder,
        itemCount: c.channelsCount,
      );

  Widget channelListItemBuilder(context, int index) {
    TelegramChannelInfo channelInfo = c.channels[index];
    return ListTile(
      key: Key(channelInfo.id.toString()),
      leading: Obx(
        () => CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey,
          backgroundImage: channelInfo.channelPhoto,
        ),
      ),
      title: Text(
        channelInfo.title,
        style: Get.theme.textTheme.headline6,
      ),
      onTap: () {
        c.showChannelMessages(channelInfo);
      },
    );
  }
}
