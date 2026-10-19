import '../../profile/models/user_profile.dart';
import '../../scan/models/nutrition_facts.dart';
import '../models/product_assessment.dart';

class AssessmentEngine {
  /// Evaluates product ingredients and nutrition facts against the user's declared profile.
  /// Generates human-explainable, evidence-based reasons for all classifications.
  static ProductAssessment evaluate({
    required UserProfile profile,
    required NutritionFacts nutrition,
    String? ingredientsText,
    String? allergenText,
  }) {
    final reasons = <AssessmentReason>[];
    final positiveHighlights = <String>[];
    final uncertaintyNotes = <String>[];

    final combinedIngredients =
        '${ingredientsText ?? ''} ${allergenText ?? ''}'.toLowerCase();

    bool hasAllergenConflict = false;
    bool hasDietaryConflict = false;
    bool hasGoalConflict = false;

    // 1. ALLERGEN CHECKS (Top Priority - Avoid 🔴)
    if (profile.allergiesAndIntolerances.isNotEmpty) {
      if (combinedIngredients.trim().isEmpty) {
        uncertaintyNotes.add(
          'Ingredient and allergen statements could not be extracted. If you have severe allergies, do not consume this product without reading the physical package.',
        );
      } else {
        for (final allergy in profile.allergiesAndIntolerances) {
          final keywords = _getAllergyKeywords(allergy);
          for (final kw in keywords) {
            if (_containsWord(combinedIngredients, kw)) {
              hasAllergenConflict = true;
              reasons.add(
                AssessmentReason(
                  title: 'Allergen Alert: $allergy',
                  detail:
                      'The packaging mentions "$kw", which matches your declared allergy to $allergy. Verify the physical package before consuming.',
                  matchedField: 'Allergen: $allergy',
                  isWarning: true,
                ),
              );
              break;
            }
          }
        }
      }
    }

    // 2. DIETARY PREFERENCE CHECKS (Vegetarian / Vegan)
    if (profile.dietaryPreferences.isNotEmpty &&
        combinedIngredients.trim().isNotEmpty) {
      for (final pref in profile.dietaryPreferences) {
        if (pref.toLowerCase().contains('vegetarian')) {
          const nonVeg = [
            'gelatin',
            'gelatine',
            'rennet',
            'carmine',
            'cochineal',
            'lard',
            'tallow',
            'chicken',
            'beef',
            'pork',
            'fish',
            'anchov',
            'shellfish',
            'shrimp',
            'crab',
          ];
          for (final item in nonVeg) {
            if (_containsWord(combinedIngredients, item)) {
              hasDietaryConflict = true;
              reasons.add(
                AssessmentReason(
                  title: 'Dietary Mismatch: Vegetarian',
                  detail:
                      'The ingredients list mentions "$item", which is typically non-vegetarian.',
                  matchedField: 'Dietary Preference: Vegetarian',
                  isWarning: true,
                ),
              );
              break;
            }
          }
        } else if (pref.toLowerCase().contains('vegan')) {
          const nonVegan = [
            'milk',
            'butter',
            'cheese',
            'whey',
            'casein',
            'egg',
            'eggs',
            'honey',
            'gelatin',
            'gelatine',
            'lactose',
            'cream',
          ];
          for (final item in nonVegan) {
            if (_containsWord(combinedIngredients, item)) {
              hasDietaryConflict = true;
              reasons.add(
                AssessmentReason(
                  title: 'Dietary Mismatch: Vegan',
                  detail:
                      'The ingredients list mentions "$item", which is derived from animal sources.',
                  matchedField: 'Dietary Preference: Vegan',
                  isWarning: true,
                ),
              );
              break;
            }
          }
        }
      }
    }

    // 3. OPTIONAL RESTRICTIONS (e.g. No Palm Oil, No Artificial Sweeteners)
    if (profile.optionalRestrictions.isNotEmpty &&
        combinedIngredients.trim().isNotEmpty) {
      for (final restriction in profile.optionalRestrictions) {
        if (restriction.toLowerCase().contains('palm oil')) {
          if (combinedIngredients.contains('palm oil') ||
              combinedIngredients.contains('palm fat') ||
              combinedIngredients.contains('palmate') ||
              combinedIngredients.contains('palmitate')) {
            reasons.add(
              AssessmentReason(
                title: 'Restriction Matched: Palm Oil',
                detail:
                    'Product contains palm oil derivatives, matching your optional restriction to avoid palm oil.',
                matchedField: 'Restriction: Palm Oil',
                isWarning: true,
              ),
            );
          }
        }
        if (restriction.toLowerCase().contains('artificial sweetener')) {
          const sweeteners = [
            'aspartame',
            'sucralose',
            'acesulfame',
            'saccharin',
            'sorbitol',
            'maltitol',
          ];
          for (final sw in sweeteners) {
            if (_containsWord(combinedIngredients, sw)) {
              reasons.add(
                AssessmentReason(
                  title: 'Restriction Matched: Artificial Sweetener',
                  detail:
                      'Contains "$sw", matching your preference to avoid artificial sweeteners.',
                  matchedField: 'Restriction: Artificial Sweetener',
                  isWarning: true,
                ),
              );
              break;
            }
          }
        }
      }
    }

    // 4. USER HEALTH GOALS
    if (nutrition.isEmpty) {
      uncertaintyNotes.add(
        'Nutrition facts table was not detected or was illegible. Nutrient-specific checks could not be verified.',
      );
    } else {
      for (final goal in profile.goals) {
        final g = goal.toLowerCase();

        // Reduce Added Sugar
        if (g.contains('sugar')) {
          if (nutrition.sugar != null) {
            if (nutrition.sugar! > 10.0) {
              hasGoalConflict = true;
              reasons.add(
                AssessmentReason(
                  title: 'High Sugar Content',
                  detail:
                      'Contains ${nutrition.sugar}g sugar per serving, which is above the low-sugar threshold (10g) for your goal.',
                  matchedField: 'Goal: Reduce Added Sugar',
                  isWarning: true,
                ),
              );
            } else if (nutrition.sugar! <= 5.0) {
              positiveHighlights.add(
                'Low in sugar: ${nutrition.sugar}g per serving aligns well with your sugar reduction goal.',
              );
            }
          } else {
            uncertaintyNotes.add(
                'Sugar content could not be read from the label to check against your sugar goal.');
          }
        }

        // Monitor Sodium / Salt
        if (g.contains('sodium') || g.contains('salt')) {
          if (nutrition.sodium != null) {
            if (nutrition.sodium! > 400.0) {
              hasGoalConflict = true;
              reasons.add(
                AssessmentReason(
                  title: 'High Sodium Content',
                  detail:
                      'Contains ${nutrition.sodium!.toInt()}mg sodium per serving. This is high and may not fit your goal of monitoring sodium intake.',
                  matchedField: 'Goal: Monitor Sodium',
                  isWarning: true,
                ),
              );
            } else if (nutrition.sodium! <= 140.0) {
              positiveHighlights.add(
                'Low sodium snack: ${nutrition.sodium!.toInt()}mg per serving fits your sodium goal.',
              );
            }
          } else {
            uncertaintyNotes.add(
                'Sodium content could not be read from the label to check against your sodium goal.');
          }
        }

        // Increase Protein
        if (g.contains('protein')) {
          if (nutrition.protein != null) {
            if (nutrition.protein! >= 8.0) {
              positiveHighlights.add(
                'High protein: ${nutrition.protein}g protein per serving supports your high-protein target.',
              );
            } else if (nutrition.protein! < 2.0) {
              reasons.add(
                AssessmentReason(
                  title: 'Low Protein Content',
                  detail:
                      'Contains only ${nutrition.protein}g protein per serving. Consider supplementing with a higher protein snack.',
                  matchedField: 'Goal: Increase Protein',
                  isWarning: false,
                ),
              );
            }
          }
        }
      }
    }

    // 5. DETERMINE OVERALL CATEGORY
    AssessmentCategory category;
    String headline;

    if (hasAllergenConflict || hasDietaryConflict) {
      category = AssessmentCategory.avoid;
      headline = 'Not Recommended: Contains Declared Allergens or Dietary Mismatches';
    } else if (hasGoalConflict) {
      category = AssessmentCategory.considerLimiting;
      headline = 'Consider Limiting: One or More Nutrient Values Exceed Your Goals';
    } else if (nutrition.isEmpty && combinedIngredients.trim().isEmpty) {
      category = AssessmentCategory.incomplete;
      headline = 'Insufficient Label Data to Form a Reliable Assessment';
    } else {
      category = AssessmentCategory.suitable;
      headline = 'Potentially Suitable: Aligns with Your Declared Goals & Preferences';
    }

    return ProductAssessment(
      category: category,
      headline: headline,
      reasons: reasons,
      positiveHighlights: positiveHighlights,
      uncertaintyNotes: uncertaintyNotes,
    );
  }

  static bool _containsWord(String text, String word) {
    final pattern = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
    return pattern.hasMatch(text);
  }

  static List<String> _getAllergyKeywords(String allergy) {
    final a = allergy.toLowerCase();
    if (a.contains('peanut')) return ['peanut', 'peanuts', 'arachis'];
    if (a.contains('dairy') || a.contains('milk')) {
      return ['milk', 'dairy', 'whey', 'casein', 'caseinate', 'butter', 'cream', 'cheese', 'lactose'];
    }
    if (a.contains('gluten') || a.contains('wheat')) {
      return ['gluten', 'wheat', 'barley', 'rye', 'malt', 'spelt', 'semolina'];
    }
    if (a.contains('soy')) return ['soy', 'soya', 'soybean', 'lecithin'];
    if (a.contains('egg')) return ['egg', 'eggs', 'albumin', 'egg white', 'egg yolk'];
    if (a.contains('tree nut')) {
      return ['almond', 'cashew', 'walnut', 'pistachio', 'hazelnut', 'pecan', 'macadamia'];
    }
    if (a.contains('fish')) return ['fish', 'cod', 'salmon', 'tuna', 'anchovy'];
    if (a.contains('shellfish')) return ['shellfish', 'shrimp', 'prawn', 'crab', 'lobster', 'clam', 'oyster'];
    return [a];
  }
}
