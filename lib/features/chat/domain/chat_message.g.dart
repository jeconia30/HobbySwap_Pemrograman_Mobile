// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String,
  threadId: json['threadId'] as String,
  senderId: json['senderId'] as String?,
  tipe: $enumDecode(_$TipePesanEnumMap, json['tipe']),
  isi: json['isi'] as String,
  payload:
      json['payload'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  sentAt: DateTime.parse(json['sentAt'] as String),
  readAt: json['readAt'] == null
      ? null
      : DateTime.parse(json['readAt'] as String),
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'threadId': instance.threadId,
      'senderId': instance.senderId,
      'tipe': _$TipePesanEnumMap[instance.tipe]!,
      'isi': instance.isi,
      'payload': instance.payload,
      'sentAt': instance.sentAt.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
    };

const _$TipePesanEnumMap = {
  TipePesan.teks: 'teks',
  TipePesan.foto: 'foto',
  TipePesan.lokasiCod: 'lokasiCod',
  TipePesan.sistem: 'sistem',
};
