import 'package:id_mvc_app_framework/framework.dart';
import 'package:id_mvc_app_framework/utils/command/MvcCommand.dart';
import 'package:telegram_service_example/app/model/channel_info.dart';
import 'package:telegram_service_example/app/model/channel_info_store.dart';
import 'package:telegram_service_example/app/screens/messages_screen.dart';

import 'load_channels_command.dart';

class MainScreenController extends MvcController {
  final channelsStore = TelegramChannelInfoStore();
  final MvcCommand channelsLoadCmd = LoadChannelsCmd.cmd();

  List<TelegramChannelInfo> get channels => channelsStore.values.toList();
  int get channelsCount => channelsStore?.values?.length ?? 0;

  void showChannelMessages(TelegramChannelInfo channelInfo) {
    Get.to(TelegramMessagesScreen(
      channelId: channelInfo.id,
      title: channelInfo.title,
    ));
  }

  void onGetChatsPressed() {
    Get.to(TelegramMessagesScreen());
  }

  void loadChats() {
    /* Worker _worker;
    _worker = ever(channelsLoadCmd, (_) {
      channelsLoadCmd.result.handleStatus(onCompleted: (_) {
        _worker.dispose();
        channelsLoadCmd.dispose();
      });
    }); */
    channelsLoadCmd.execute();
  }

  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  @override
  void dispose() {
    channelsLoadCmd.dispose();
    super.dispose();
  }
}
