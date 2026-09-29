// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_thread.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatThread {

 String get id;/// Tepat dua user (penyewa & pemilik).
 List<String> get participantIds; String get itemId;/// Sewa terbaru pasangan ini untuk barang tsb. (null = belum ada sewa).
 String? get bookingId; DateTime get lastMessageAt;/// Jumlah pesan belum dibaca, per user.
 Map<String, int> get unreadCount;/// Notifikasi dibisukan, per user.
 Map<String, bool> get muted;
/// Create a copy of ChatThread
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatThreadCopyWith<ChatThread> get copyWith => _$ChatThreadCopyWithImpl<ChatThread>(this as ChatThread, _$identity);

  /// Serializes this ChatThread to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChatThread;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatThread&&(identical(other.id, _this.id) || other.id == _this.id)&&const DeepCollectionEquality().equals(other.participantIds, _this.participantIds)&&(identical(other.itemId, _this.itemId) || other.itemId == _this.itemId)&&(identical(other.bookingId, _this.bookingId) || other.bookingId == _this.bookingId)&&(identical(other.lastMessageAt, _this.lastMessageAt) || other.lastMessageAt == _this.lastMessageAt)&&const DeepCollectionEquality().equals(other.unreadCount, _this.unreadCount)&&const DeepCollectionEquality().equals(other.muted, _this.muted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChatThread;
  return Object.hash(runtimeType,_this.id,const DeepCollectionEquality().hash(_this.participantIds),_this.itemId,_this.bookingId,_this.lastMessageAt,const DeepCollectionEquality().hash(_this.unreadCount),const DeepCollectionEquality().hash(_this.muted));
}

@override
String toString() {
  final _this = this as ChatThread;
  return 'ChatThread(id: ${_this.id}, participantIds: ${_this.participantIds}, itemId: ${_this.itemId}, bookingId: ${_this.bookingId}, lastMessageAt: ${_this.lastMessageAt}, unreadCount: ${_this.unreadCount}, muted: ${_this.muted})';
}


}

/// @nodoc
abstract mixin class $ChatThreadCopyWith<$Res>  {
  factory $ChatThreadCopyWith(ChatThread value, $Res Function(ChatThread) _then) = _$ChatThreadCopyWithImpl;
@useResult
$Res call({
 String id, List<String> participantIds, String itemId, String? bookingId, DateTime lastMessageAt, Map<String, int> unreadCount, Map<String, bool> muted
});




}
/// @nodoc
class _$ChatThreadCopyWithImpl<$Res>
    implements $ChatThreadCopyWith<$Res> {
  _$ChatThreadCopyWithImpl(this._self, this._then);

  final ChatThread _self;
  final $Res Function(ChatThread) _then;

/// Create a copy of ChatThread
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? participantIds = null,Object? itemId = null,Object? bookingId = freezed,Object? lastMessageAt = null,Object? unreadCount = null,Object? muted = null,}) {
  return _then(ChatThread(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,participantIds: null == participantIds ? _self.participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: null == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as Map<String, int>,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatThread].
extension ChatThreadPatterns on ChatThread {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatThread value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatThread() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatThread value)  $default,){
final _that = this;
switch (_that) {
case _ChatThread():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatThread value)?  $default,){
final _that = this;
switch (_that) {
case _ChatThread() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<String> participantIds,  String itemId,  String? bookingId,  DateTime lastMessageAt,  Map<String, int> unreadCount,  Map<String, bool> muted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatThread() when $default != null:
return $default(_that.id,_that.participantIds,_that.itemId,_that.bookingId,_that.lastMessageAt,_that.unreadCount,_that.muted);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<String> participantIds,  String itemId,  String? bookingId,  DateTime lastMessageAt,  Map<String, int> unreadCount,  Map<String, bool> muted)  $default,) {final _that = this;
switch (_that) {
case _ChatThread():
return $default(_that.id,_that.participantIds,_that.itemId,_that.bookingId,_that.lastMessageAt,_that.unreadCount,_that.muted);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<String> participantIds,  String itemId,  String? bookingId,  DateTime lastMessageAt,  Map<String, int> unreadCount,  Map<String, bool> muted)?  $default,) {final _that = this;
switch (_that) {
case _ChatThread() when $default != null:
return $default(_that.id,_that.participantIds,_that.itemId,_that.bookingId,_that.lastMessageAt,_that.unreadCount,_that.muted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatThread extends ChatThread {
  const _ChatThread({required this.id, required  List<String> participantIds, required this.itemId, this.bookingId, required this.lastMessageAt,  Map<String, int> unreadCount = const <String, int>{},  Map<String, bool> muted = const <String, bool>{}}): _participantIds = participantIds,_unreadCount = unreadCount,_muted = muted,super._();
  factory _ChatThread.fromJson(Map<String, dynamic> json) => _$ChatThreadFromJson(json);

@override final  String id;
/// Tepat dua user (penyewa & pemilik).
 final  List<String> _participantIds;
/// Tepat dua user (penyewa & pemilik).
@override List<String> get participantIds {
  if (_participantIds is EqualUnmodifiableListView) return _participantIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantIds);
}

@override final  String itemId;
/// Sewa terbaru pasangan ini untuk barang tsb. (null = belum ada sewa).
@override final  String? bookingId;
@override final  DateTime lastMessageAt;
/// Jumlah pesan belum dibaca, per user.
 final  Map<String, int> _unreadCount;
/// Jumlah pesan belum dibaca, per user.
@override@JsonKey() Map<String, int> get unreadCount {
  if (_unreadCount is EqualUnmodifiableMapView) return _unreadCount;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_unreadCount);
}

/// Notifikasi dibisukan, per user.
 final  Map<String, bool> _muted;
/// Notifikasi dibisukan, per user.
@override@JsonKey() Map<String, bool> get muted {
  if (_muted is EqualUnmodifiableMapView) return _muted;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_muted);
}


/// Create a copy of ChatThread
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatThreadCopyWith<_ChatThread> get copyWith => __$ChatThreadCopyWithImpl<_ChatThread>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatThreadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThread&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.participantIds, _participantIds)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&const DeepCollectionEquality().equals(other.unreadCount, _unreadCount)&&const DeepCollectionEquality().equals(other.muted, _muted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_participantIds),itemId,bookingId,lastMessageAt,const DeepCollectionEquality().hash(_unreadCount),const DeepCollectionEquality().hash(_muted));
}

@override
String toString() {
    return 'ChatThread(id: $id, participantIds: $participantIds, itemId: $itemId, bookingId: $bookingId, lastMessageAt: $lastMessageAt, unreadCount: $unreadCount, muted: $muted)';
}


}

/// @nodoc
abstract mixin class _$ChatThreadCopyWith<$Res> implements $ChatThreadCopyWith<$Res> {
  factory _$ChatThreadCopyWith(_ChatThread value, $Res Function(_ChatThread) _then) = __$ChatThreadCopyWithImpl;
@override @useResult
$Res call({
 String id, List<String> participantIds, String itemId, String? bookingId, DateTime lastMessageAt, Map<String, int> unreadCount, Map<String, bool> muted
});




}
/// @nodoc
class __$ChatThreadCopyWithImpl<$Res>
    implements _$ChatThreadCopyWith<$Res> {
  __$ChatThreadCopyWithImpl(this._self, this._then);

  final _ChatThread _self;
  final $Res Function(_ChatThread) _then;

/// Create a copy of ChatThread
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? participantIds = null,Object? itemId = null,Object? bookingId = freezed,Object? lastMessageAt = null,Object? unreadCount = null,Object? muted = null,}) {
  return _then(_ChatThread(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,participantIds: null == participantIds ? _self._participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: null == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime,unreadCount: null == unreadCount ? _self._unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as Map<String, int>,muted: null == muted ? _self._muted : muted // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,
  ));
}


}

// dart format on
