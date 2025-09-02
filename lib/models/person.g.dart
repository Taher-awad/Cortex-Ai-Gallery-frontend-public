// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Person _$PersonFromJson(Map<String, dynamic> json) => Person(
      personId: json['person_id'] as String,
      name: json['name'] as String? ?? 'Unknown Person',
      faceCount: (json['face_count'] as num).toInt(),
      coverThumbnailUrl: json['cover_thumbnail_url'] as String,
    );

Map<String, dynamic> _$PersonToJson(Person instance) => <String, dynamic>{
      'person_id': instance.personId,
      'name': instance.name,
      'face_count': instance.faceCount,
      'cover_thumbnail_url': instance.coverThumbnailUrl,
    };
