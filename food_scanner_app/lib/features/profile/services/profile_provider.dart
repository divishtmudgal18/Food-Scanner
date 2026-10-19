import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileProvider with ChangeNotifier {
  static const String _storageKey = 'food_scanner_user_profile';
  UserProfile _profile = UserProfile.defaultProfile();
  bool _isLoading = true;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;

  ProfileProvider() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        _profile = UserProfile.fromJson(map);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserProfile updated) async {
    _profile = updated;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_profile.toJson()));
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }

  void toggleDietaryPreference(String preference) {
    final list = List<String>.from(_profile.dietaryPreferences);
    if (list.contains(preference)) {
      list.remove(preference);
    } else {
      list.add(preference);
    }
    updateProfile(_profile.copyWith(dietaryPreferences: list));
  }

  void toggleAllergy(String allergy) {
    final list = List<String>.from(_profile.allergiesAndIntolerances);
    if (list.contains(allergy)) {
      list.remove(allergy);
    } else {
      list.add(allergy);
    }
    updateProfile(_profile.copyWith(allergiesAndIntolerances: list));
  }

  void toggleGoal(String goal) {
    final list = List<String>.from(_profile.goals);
    if (list.contains(goal)) {
      list.remove(goal);
    } else {
      list.add(goal);
    }
    updateProfile(_profile.copyWith(goals: list));
  }

  void toggleRestriction(String restriction) {
    final list = List<String>.from(_profile.optionalRestrictions);
    if (list.contains(restriction)) {
      list.remove(restriction);
    } else {
      list.add(restriction);
    }
    updateProfile(_profile.copyWith(optionalRestrictions: list));
  }
}
