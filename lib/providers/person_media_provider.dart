import 'package:flutter/material.dart';
import 'package:cortex_ai_gallery/models/media_item.dart';
import 'package:cortex_ai_gallery/services/api_service.dart';

class PersonMediaProvider with ChangeNotifier {
  final ApiService _apiService;

  List<MediaItem> _mediaItems = [];
  List<MediaItem> get mediaItems => _mediaItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PersonMediaProvider(this._apiService);

  Future<void> fetchMedia(String personId) async {
    _isLoading = true;
    _mediaItems = []; // Clear previous results
    notifyListeners();

    final newItems = await _apiService.getMediaForPerson(personId);

    _mediaItems = newItems;
    _isLoading = false;
    notifyListeners();
  }
}
