import 'package:freezed_annotation/freezed_annotation.dart';

part 'mistake.freezed.dart';
part 'mistake.g.dart';

@freezed
class Mistake with _$Mistake {
  factory Mistake({
    required int offset,
    required int length,
    required List<String> suggestions,
  }) = _Mistake;

  factory Mistake.fromJson(Map<String, dynamic> json) =>
      _$MistakeFromJson(json);
}
