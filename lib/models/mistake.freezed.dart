// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mistake.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Mistake _$MistakeFromJson(Map<String, dynamic> json) {
  return _Mistake.fromJson(json);
}

/// @nodoc
mixin _$Mistake {
  int get offset => throw _privateConstructorUsedError;
  int get length => throw _privateConstructorUsedError;
  List<String> get suggestions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MistakeCopyWith<Mistake> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MistakeCopyWith<$Res> {
  factory $MistakeCopyWith(Mistake value, $Res Function(Mistake) then) =
      _$MistakeCopyWithImpl<$Res, Mistake>;
  @useResult
  $Res call({int offset, int length, List<String> suggestions});
}

/// @nodoc
class _$MistakeCopyWithImpl<$Res, $Val extends Mistake>
    implements $MistakeCopyWith<$Res> {
  _$MistakeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? offset = null,
    Object? length = null,
    Object? suggestions = null,
  }) {
    return _then(_value.copyWith(
      offset: null == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
      length: null == length
          ? _value.length
          : length // ignore: cast_nullable_to_non_nullable
              as int,
      suggestions: null == suggestions
          ? _value.suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MistakeImplCopyWith<$Res> implements $MistakeCopyWith<$Res> {
  factory _$$MistakeImplCopyWith(
          _$MistakeImpl value, $Res Function(_$MistakeImpl) then) =
      __$$MistakeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int offset, int length, List<String> suggestions});
}

/// @nodoc
class __$$MistakeImplCopyWithImpl<$Res>
    extends _$MistakeCopyWithImpl<$Res, _$MistakeImpl>
    implements _$$MistakeImplCopyWith<$Res> {
  __$$MistakeImplCopyWithImpl(
      _$MistakeImpl _value, $Res Function(_$MistakeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? offset = null,
    Object? length = null,
    Object? suggestions = null,
  }) {
    return _then(_$MistakeImpl(
      offset: null == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
      length: null == length
          ? _value.length
          : length // ignore: cast_nullable_to_non_nullable
              as int,
      suggestions: null == suggestions
          ? _value._suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MistakeImpl implements _Mistake {
  _$MistakeImpl(
      {required this.offset,
      required this.length,
      required final List<String> suggestions})
      : _suggestions = suggestions;

  factory _$MistakeImpl.fromJson(Map<String, dynamic> json) =>
      _$$MistakeImplFromJson(json);

  @override
  final int offset;
  @override
  final int length;
  final List<String> _suggestions;
  @override
  List<String> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  @override
  String toString() {
    return 'Mistake(offset: $offset, length: $length, suggestions: $suggestions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MistakeImpl &&
            (identical(other.offset, offset) || other.offset == offset) &&
            (identical(other.length, length) || other.length == length) &&
            const DeepCollectionEquality()
                .equals(other._suggestions, _suggestions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, offset, length,
      const DeepCollectionEquality().hash(_suggestions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MistakeImplCopyWith<_$MistakeImpl> get copyWith =>
      __$$MistakeImplCopyWithImpl<_$MistakeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MistakeImplToJson(
      this,
    );
  }
}

abstract class _Mistake implements Mistake {
  factory _Mistake(
      {required final int offset,
      required final int length,
      required final List<String> suggestions}) = _$MistakeImpl;

  factory _Mistake.fromJson(Map<String, dynamic> json) = _$MistakeImpl.fromJson;

  @override
  int get offset;
  @override
  int get length;
  @override
  List<String> get suggestions;
  @override
  @JsonKey(ignore: true)
  _$$MistakeImplCopyWith<_$MistakeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
