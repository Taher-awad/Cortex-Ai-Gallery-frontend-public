import 'package:flutter/material.dart';
import 'package:cortex_ai_gallery/models/person.dart';
import 'package:cortex_ai_gallery/services/api_service.dart';

class PeopleProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Person> _people = [];
  List<Person> get people => _people;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  PeopleProvider(this._apiService) {
    fetchPeople();
  }

  Future<void> fetchPeople() async {
    _isLoading = true;
    notifyListeners();

    _people = await _apiService.getPeople();

    _isLoading = false;
    notifyListeners();
  }

  // ADDED: A refresh method for programmatic updates
  Future<void> refresh() async {
    // We don't set loading to true here to make the refresh smoother
    _people = await _apiService.getPeople();
    notifyListeners();
  }
}