import 'package:id_mvc_app_framework/framework.dart';

import 'channel_info.dart';

class TelegramChannelInfoStore extends RxMap<int, TelegramChannelInfo>
    with GetxServiceMixin {
  TelegramChannelInfoStore._() : super(Map());

  factory TelegramChannelInfoStore() {
    return Get.put(TelegramChannelInfoStore._());
  }

  // JSON serialization/deserialization
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    values.forEach((i) =>{
      data[i.id.toString()]=i.toJson()
    });
    return data;
  }

  // Getting the sorted list of all channels by date
  // the list can be adjusted by stat position and desired length
  List<TelegramChannelInfo> sortMessagesByDate
      (TelegramChannelSortDirection direction, [int offset=0, int limit=0]){

    if(values==null) return null;
    if(limit==0) limit = values.length-offset-1;
    List<TelegramChannelInfo> channels = values.toList();
    if(direction==TelegramChannelSortDirection.asc)
      channels.sort(compareChannelsByRecencyAsc);
    else
      channels.sort(compareChannelsByRecencyDesc);
    return channels.sublist(offset, offset+limit);
  }

  // Comparator functions for sorting
  int compareChannelsByRecencyAsc(TelegramChannelInfo a,
      TelegramChannelInfo b){
    if(a.position<b.position)
      return -1;
    else return 1;
  }

  int compareChannelsByRecencyDesc(TelegramChannelInfo a,
      TelegramChannelInfo b){
    if(a.position<b.position)
      return 1;
    else return -1;
  }
}

enum TelegramChannelSortDirection {
  asc,
  desc
}