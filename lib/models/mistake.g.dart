// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mistake.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MistakeImpl _$$MistakeImplFromJson(Map<String, dynamic> json) =>
    _$MistakeImpl(
      offset: (json['offset'] as num).toInt(),
      length: (json['length'] as num).toInt(),
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$MistakeImplToJson(_$MistakeImpl instance) =>
    <String, dynamic>{
      'offset': instance.offset,
      'length': instance.length,
      'suggestions': instance.suggestions,
    };
