// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatThread _$ChatThreadFromJson(Map<String, dynamic> json) => _ChatThread(
  id: json['id'] as String,
  participantIds: (json['participantIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  itemId: json['itemId'] as String,
  bookingId: json['bookingId'] as String?,
  lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
  unreadCount:
      (json['unreadCount'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  muted:
      (json['muted'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const <String, bool>{},
);

Map<String, dynamic> _$ChatThreadToJson(_ChatThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'participantIds': instance.participantIds,
      'itemId': instance.itemId,
      'bookingId': instance.bookingId,
      'lastMessageAt': instance.lastMessageAt.toIso8601String(),
      'unreadCount': instance.unreadCount,
      'muted': instance.muted,
    };
