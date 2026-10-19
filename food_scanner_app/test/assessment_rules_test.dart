import 'package:flutter_test/flutter_test.dart';
import 'package:food_scanner_app/features/profile/models/user_profile.dart';
import 'package:food_scanner_app/features/scan/models/nutrition_facts.dart';
import 'package:food_scanner_app/features/assessment/models/product_assessment.dart';
import 'package:food_scanner_app/features/assessment/services/assessment_engine.dart';

void main() {
  group('AssessmentEngine Unit Tests', () {
    test('Flags direct allergen conflict (Peanuts)', () {
      final profile = UserProfile(
        userId: 'u1',
        name: 'Allergy User',
        email: 'test@demo.com',
        allergiesAndIntolerances: ['Peanuts'],
      );

      final assessment = AssessmentEngine.evaluate(
        profile: profile,
        nutrition: const NutritionFacts(sugar: 4.0, calories: 120),
        ingredientsText: 'Roasted peanuts, vegetable oil, salt.',
      );

      expect(assessment.category, equals(AssessmentCategory.avoid));
      expect(
        assessment.reasons.any((r) => r.title.contains('Allergen Alert')),
        isTrue,
      );
    });

    test('Flags vegetarian mismatch when gelatin is in ingredients', () {
      final profile = UserProfile(
        userId: 'u2',
        name: 'Veg User',
        email: 'test@demo.com',
        dietaryPreferences: ['Vegetarian'],
      );

      final assessment = AssessmentEngine.evaluate(
        profile: profile,
        nutrition: const NutritionFacts(sugar: 5.0),
        ingredientsText: 'Sugar, glucose syrup, gelatin, citric acid.',
      );

      expect(assessment.category, equals(AssessmentCategory.avoid));
      expect(
        assessment.reasons.any((r) => r.title.contains('Vegetarian')),
        isTrue,
      );
    });

    test('Flags high sugar when user has Reduce Added Sugar goal', () {
      final profile = UserProfile(
        userId: 'u3',
        name: 'Sugar Watcher',
        email: 'test@demo.com',
        goals: ['Reduce Added Sugar'],
      );

      final assessment = AssessmentEngine.evaluate(
        profile: profile,
        nutrition: const NutritionFacts(sugar: 18.0, calories: 250),
        ingredientsText: 'Wheat flour, cocoa butter, sugar.',
      );

      expect(assessment.category, equals(AssessmentCategory.considerLimiting));
      expect(
        assessment.reasons.any((r) => r.title.contains('High Sugar Content')),
        isTrue,
      );
    });

    test('Marks product as suitable when it aligns with goals and preferences',
        () {
      final profile = UserProfile(
        userId: 'u4',
        name: 'Healthy Eater',
        email: 'test@demo.com',
        dietaryPreferences: ['Vegetarian'],
        goals: ['Reduce Added Sugar', 'Monitor Sodium / Salt'],
      );

      final assessment = AssessmentEngine.evaluate(
        profile: profile,
        nutrition: const NutritionFacts(
          sugar: 2.0,
          sodium: 90.0,
          protein: 9.0,
          calories: 140,
        ),
        ingredientsText: 'Rolled oats, chia seeds, almonds, cinnamon.',
      );

      expect(assessment.category, equals(AssessmentCategory.suitable));
      expect(assessment.positiveHighlights.isNotEmpty, isTrue);
    });

    test('Handles incomplete label data gracefully', () {
      final profile = UserProfile.defaultProfile();

      final assessment = AssessmentEngine.evaluate(
        profile: profile,
        nutrition: const NutritionFacts(), // Empty
        ingredientsText: null,
      );

      expect(assessment.category, equals(AssessmentCategory.incomplete));
      expect(assessment.uncertaintyNotes.isNotEmpty, isTrue);
    });
  });
}
