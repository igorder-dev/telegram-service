// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelegramChannelInfo _$TelegramChannelInfoFromJson(Map<String, dynamic> json) {
  return TelegramChannelInfo(
    json['id'] as int,
    json['title'] as String,
    const RxChatPhotoInfoSerializer()
        .fromJson(json['photoInfoRx'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$TelegramChannelInfoToJson(
        TelegramChannelInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'photoInfoRx':
          const RxChatPhotoInfoSerializer().toJson(instance.photoInfoRx),
    };
