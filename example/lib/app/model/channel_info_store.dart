import 'package:id_mvc_app_framework/framework.dart';

import 'channel_info.dart';

class TelegramChannelInfoStore extends RxMap<int, TelegramChannelInfo>
    with GetxServiceMixin {
  TelegramChannelInfoStore._() : super(Map());

  Map<int, TelegramChannelInfo> get pureMap => this.value;

  factory TelegramChannelInfoStore() {
    return Get.put(TelegramChannelInfoStore._());
  }
}
