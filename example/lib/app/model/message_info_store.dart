import 'package:id_mvc_app_framework/framework.dart';

import 'message_info.dart';

class TelegramChannelMessageInfoStore
    extends RxMap<int, TelegramChannelMessageInfo> with GetxServiceMixin {
  TelegramChannelMessageInfoStore._() : super(Map());

  factory TelegramChannelMessageInfoStore() {
    return Get.put(TelegramChannelMessageInfoStore._());
  }

  List<TelegramChannelMessageInfo> getMessagesByChannelId({int channelId}) =>
      (channelId == null
          ? values?.toList()?.reversed?.toList()
          : values
              ?.where((message) => message.channelId == channelId)
              ?.toList()
              ?.reversed
              ?.toList()) ??
      List();

  // Getting the sorted list of all messages by view count
  // the list can be adjusted by stat position and desired length
  List<TelegramChannelMessageInfo> sortMessagesByPopularity
      (TelegramMessageSortDirection direction, [int offset=0, int limit=0]){

    if(values==null) return null;
    if(limit==0) limit = values.length-offset-1;
    List<TelegramChannelMessageInfo> messages = values.toList();
    if(direction==TelegramMessageSortDirection.asc)
      messages.sort(compareMessagesByPopularityAsc);
    else
      messages.sort(compareMessagesByPopularityDesc);
    return messages.sublist(offset, offset+limit);
  }

  // Getting the sorted list of all messages by date
  // the list can be adjusted by stat position and desired length
  List<TelegramChannelMessageInfo> sortMessagesByDate
      (TelegramMessageSortDirection direction, [int offset=0, int limit=0]){

    if(values==null) return null;
    if(limit==0) limit = values.length-offset-1;
    List<TelegramChannelMessageInfo> messages = values.toList();
    if(direction==TelegramMessageSortDirection.asc)
      messages.sort(compareMessagesByRecencyAsc);
    else
      messages.sort(compareMessagesByRecencyDesc);
    return messages.sublist(offset, offset+limit);
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

  // Comparator functions for sorting
  int compareMessagesByPopularityAsc(TelegramChannelMessageInfo a,
      TelegramChannelMessageInfo b){
    if(a.viewsCount<b.viewsCount)
      return -1;
    else return 1;
  }

  int compareMessagesByPopularityDesc(TelegramChannelMessageInfo a,
      TelegramChannelMessageInfo b){
    if(a.viewsCount<b.viewsCount)
      return 1;
    else return -1;
  }

  int compareMessagesByRecencyAsc(TelegramChannelMessageInfo a,
      TelegramChannelMessageInfo b){
    if(a.messageTimeStamp<b.messageTimeStamp)
      return -1;
    else return 1;
  }

  int compareMessagesByRecencyDesc(TelegramChannelMessageInfo a,
      TelegramChannelMessageInfo b){
    if(a.messageTimeStamp<b.messageTimeStamp)
      return 1;
    else return -1;
  }
}

enum TelegramMessageSortDirection {
  asc,
  desc
}