import 'package:json_annotation/json_annotation.dart';

part 'media_item.g.dart';

@JsonSerializable()
class MediaItem {
  final String id;
  @JsonKey(name: 'original_filename')
  final String originalFilename;
  @JsonKey(name: 'media_url')
  final String mediaUrl;
  @JsonKey(name: 'thumbnail_url')
  final String thumbnailUrl;
  @JsonKey(name: 'face_count')
  final int faceCount;
  final String? caption;
  @JsonKey(name: 'processed_at')
  final DateTime processedAt;
  @JsonKey(name: 'file_type')
  final String fileType;

  MediaItem({
    required this.id,
    required this.originalFilename,
    required this.mediaUrl,
    required this.thumbnailUrl,
    required this.faceCount,
    this.caption,
    required this.processedAt,
    required this.fileType,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) => _$MediaItemFromJson(json);
  Map<String, dynamic> toJson() => _$MediaItemToJson(this);
}