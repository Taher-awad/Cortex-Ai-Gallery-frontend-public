import 'package:flutter/material.dart';
import 'package:cortex_ai_gallery/models/media_item.dart';
import 'package:cortex_ai_gallery/services/api_service.dart';

class MediaProvider with ChangeNotifier {
  final ApiService _apiService;

  List<MediaItem> _mediaItems = [];
  List<MediaItem> get mediaItems => _mediaItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _offset = 0;
  final int _limit = 30;

  MediaProvider(this._apiService) {
    fetchMedia();
  }

  Future<void> fetchMedia() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newItems = await _apiService.getMedia(limit: _limit, offset: _offset);

      if (newItems.length < _limit) {
        _hasMore = false;
      }

      _mediaItems.addAll(newItems);
      _offset += _limit;
    } catch (e) {
      _error = "Failed to fetch media. Please try again.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _mediaItems = [];
    _offset = 0;
    _hasMore = true;
    _isLoading = false; // Reset loading state before fetching
    _error = null;
    await fetchMedia();
    // No need for an extra notifyListeners() here, fetchMedia handles it.
  }
}