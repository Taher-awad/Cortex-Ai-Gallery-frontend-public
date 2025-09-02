import 'package:json_annotation/json_annotation.dart';

part 'person.g.dart';

@JsonSerializable()
class Person {
  @JsonKey(name: 'person_id')
  final String personId;

  // CORRECTED: Provide a default value to handle null names from the API
  @JsonKey(defaultValue: 'Unknown Person')
  final String name;

  @JsonKey(name: 'face_count')
  final int faceCount;

  @JsonKey(name: 'cover_thumbnail_url')
  final String coverThumbnailUrl;

  Person({
    required this.personId,
    required this.name,
    required this.faceCount,
    required this.coverThumbnailUrl,
  });

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}