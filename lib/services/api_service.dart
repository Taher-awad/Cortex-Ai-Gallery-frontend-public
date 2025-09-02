import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cortex_ai_gallery/models/media_item.dart';
import 'package:cortex_ai_gallery/models/person.dart';

class ApiService {
  final Dio _dio = Dio();
  // IMPORTANT: Replace with your actual backend URL
  static const String _baseUrl = 'http://192.168.0.140:8000'; // 10.0.2.2 for Android emulator

  ApiService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
  }

  Future<List<MediaItem>> getMedia({int limit = 50, int offset = 0}) async {
    try {
      final response = await _dio.get('/media', queryParameters: {'limit': limit, 'offset': offset});
      return (response.data as List).map((json) => MediaItem.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching media: $e');
      return [];
    }
  }

  Future<List<Person>> getPeople() async {
    try {
      final response = await _dio.get('/people');
      return (response.data as List).map((json) => Person.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching people: $e');
      return [];
    }
  }

  Future<List<MediaItem>> getMediaForPerson(String personId) async {
    try {
      final response = await _dio.get('/people/$personId');
      return (response.data as List)
          .map((json) => MediaItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching media for person $personId: $e');
      return [];
    }
  }

  Future<bool> updatePersonName(String personId, String name) async {
    try {
      final response = await _dio.put(
        '/people/$personId/name',
        data: {'name': name},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating person name for $personId: $e');
      return false;
    }
  }

  Future<List<String>> checkHashes(List<String> hashes) async {
    try {
      final response = await _dio.post('/upload/check-hashes', data: {'hashes': hashes});
      return List<String>.from(response.data['needed_hashes']);
    } catch (e) {
      print('Error checking hashes: $e');
      return [];
    }
  }

  Future<bool> uploadFiles(List<File> files) async {
    try {
      final formData = FormData();
      for (var file in files) {
        formData.files.add(MapEntry('files', await MultipartFile.fromFile(file.path)));
      }
      final response = await _dio.post('/upload', data: formData);
      return response.statusCode == 202;
    } catch (e) {
      print('Error uploading files: $e');
      return false;
    }
  }
}