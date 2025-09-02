// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaItem _$MediaItemFromJson(Map<String, dynamic> json) => MediaItem(
      id: json['id'] as String,
      originalFilename: json['original_filename'] as String,
      mediaUrl: json['media_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      faceCount: (json['face_count'] as num).toInt(),
      caption: json['caption'] as String?,
      processedAt: DateTime.parse(json['processed_at'] as String),
      fileType: json['file_type'] as String,
    );

Map<String, dynamic> _$MediaItemToJson(MediaItem instance) => <String, dynamic>{
      'id': instance.id,
      'original_filename': instance.originalFilename,
      'media_url': instance.mediaUrl,
      'thumbnail_url': instance.thumbnailUrl,
      'face_count': instance.faceCount,
      'caption': instance.caption,
      'processed_at': instance.processedAt.toIso8601String(),
      'file_type': instance.fileType,
    };
