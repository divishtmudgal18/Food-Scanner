import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_scan.dart';

class HistoryProvider with ChangeNotifier {
  static const String _storageKey = 'food_scanner_scans_history';
  List<ProductScan> _scans = [];
  bool _isLoading = true;

  List<ProductScan> get scans => List.unmodifiable(_scans);
  bool get isLoading => _isLoading;

  HistoryProvider() {
    loadScans();
  }

  Future<void> loadScans() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final listStr = prefs.getStringList(_storageKey);
      if (listStr != null) {
        _scans = listStr
            .map((str) => ProductScan.fromJson(jsonDecode(str) as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading scan history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveScan(ProductScan scan) async {
    // Insert new scan at the beginning of the list
    _scans.insert(0, scan);
    notifyListeners();
    await _persist();
  }

  Future<void> deleteScan(String scanId) async {
    _scans.removeWhere((s) => s.scanId == scanId);
    notifyListeners();
    await _persist();
  }

  Future<void> clearHistory() async {
    _scans.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listStr = _scans.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList(_storageKey, listStr);
    } catch (e) {
      debugPrint('Error persisting scan history: $e');
    }
  }
}
