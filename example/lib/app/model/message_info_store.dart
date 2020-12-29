import 'package:id_mvc_app_framework/framework.dart';

import 'message_info.dart';

class TelegramChannelMessageInfoStore
    extends RxMap<int, TelegramChannelMessageInfo> with GetxServiceMixin {
  TelegramChannelMessageInfoStore._() : super(Map());

  List<TelegramChannelMessageInfo> getMessagesByChannelId({int channelId}) =>
      (channelId == null
          ? values?.toList()?.reversed?.toList()
          : values
              ?.where((message) => message.channelId == channelId)
              ?.toList()
              ?.reversed
              ?.toList()) ??
      List();

  Map<int, TelegramChannelMessageInfo> get pureMap => this.value;

  factory TelegramChannelMessageInfoStore() {
    return Get.put(TelegramChannelMessageInfoStore._());
  }
}
