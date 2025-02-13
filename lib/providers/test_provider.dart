import 'package:flutter/material.dart';
import 'package:testify/models/banner.dart' as banner_model;
import 'package:testify/models/test_series.dart';
import 'package:testify/services/test_series_service.dart';

class TestProvider with ChangeNotifier {
  List<TestSeries> _testSeries = [];
  List<banner_model.Banner> _banners = [];
  bool _isLoading = false;

  List<TestSeries> get testSeries => _testSeries;
  List<banner_model.Banner> get banners => _banners;
  bool get isLoading => _isLoading;

  Future<void> fetchTestSeries(String subExamId, BuildContext context,
      {bool forceRefresh = false}) async {
    if (_isLoading) return; // Prevent multiple simultaneous fetches

    try {
      final service = await TestSeriesService.create(context);
      final newTestSeries =
          await service.getTestSeries(subExamId, forceRefresh: forceRefresh);

      // Update state only if the widget is still mounted
      _testSeries = newTestSeries;
      notifyListeners();
    } catch (e) {
      // Handle error if needed
      _testSeries = [];
      notifyListeners();
    }
  }
  Future<void> fetchBanners(String subExamId, BuildContext context,
      {bool forceRefresh = false}) async {
    if (_isLoading) return; // Prevent multiple simultaneous fetches

    try {
      final service = await TestSeriesService.create(context);
      final newBanners =
          await service.getBanners(subExamId, forceRefresh: forceRefresh);

      // Update state only if the widget is still mounted
      _banners = newBanners;
      notifyListeners();
    } catch (e) {
      // Handle error if needed
      _banners = [];
      notifyListeners();
    }
  }

  // Fetch tests from mock data or API (initially using mock data)
  // Future<void> fetchTests() async {
  //   _isLoading = true;
  //   notifyListeners();
  //   _tests = TestData.mockTests;
  //   _isLoading = false;
  //   notifyListeners();
  // }

  // // Fetch a test by ID
  // Test? getTestById(String id) {
  //   try {
  //     return _tests.firstWhere((test) => test.id == id);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // // Add a new test
  // void addTest(Test test) {
  //   _tests.add(test);
  //   notifyListeners();
  // }

  // // Remove a test by ID
  // void removeTest(String id) {
  //   _tests.removeWhere((test) => test.id == id);
  //   notifyListeners();
  // }
}
