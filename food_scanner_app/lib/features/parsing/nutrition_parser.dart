import '../scan/models/nutrition_facts.dart';

class NutritionParser {
  /// Extracts structured nutrition facts, ingredients, and allergen statements from raw OCR text.
  static ParsedPackagingData parse(String ocrText) {
    final textUpper = ocrText.toUpperCase();

    final ingredients = _extractIngredients(ocrText, textUpper);
    final allergens = _extractAllergens(ocrText, textUpper);
    final nutrition = _extractNutritionFacts(ocrText, textUpper);
    final (productName, brand) = _extractProductAndBrand(ocrText);

    return ParsedPackagingData(
      productName: productName,
      brand: brand,
      ingredients: ingredients,
      allergens: allergens,
      nutritionFacts: nutrition,
      rawOcrText: ocrText,
    );
  }

  static String? _extractIngredients(String raw, String upper) {
    final regex = RegExp(
      r'(?:INGREDIENTS|INGREDIENT LIST)[:\s]+([\s\S]*?)(?=(?:NUTRITION|ALLERGEN|ALLERGY|CONTAINS|STORE|KEEP|MANUFACTURED|BEST BEFORE|USE BY|BATCH|\n\n\n|$))',
      caseSensitive: false,
    );
    final match = regex.firstMatch(raw);
    if (match != null && match.group(1) != null) {
      final cleaned = match.group(1)!.replaceAll('\n', ' ').trim();
      if (cleaned.isNotEmpty) {
        return cleaned;
      }
    }
    return null;
  }

  static String? _extractAllergens(String raw, String upper) {
    final regex = RegExp(
      r'(?:ALLERGENS?|ALLERGY ADVICE|CONTAINS|MAY CONTAIN)[:\s]+([\s\S]*?)(?=(?:NUTRITION|INGREDIENT|STORE|KEEP|MANUFACTURED|BEST BEFORE|USE BY|BATCH|\n\n|$))',
      caseSensitive: false,
    );
    final match = regex.firstMatch(raw);
    if (match != null && match.group(1) != null) {
      final cleaned = match.group(1)!.replaceAll('\n', ' ').trim();
      if (cleaned.isNotEmpty) {
        return cleaned;
      }
    }
    return null;
  }

  static NutritionFacts _extractNutritionFacts(String raw, String upper) {
    double? servingSize;
    String? servingUnit;
    double? calories;
    double? carbs;
    double? sugar;
    double? addedSugar;
    double? fiber;
    double? protein;
    double? totalFat;
    double? satFat;
    double? transFat;
    double? sodium;

    // Serving Size: e.g. "Serving Size: 30g" or "Serving Size: 1 bar (40 g)"
    final servingMatch = RegExp(
      r'SERVING SIZE[:\s]+(?:[^\d\n]*?)?(\d+(?:\.\d+)?)\s*(G|ML|OZ|PIECE)?',
    ).firstMatch(upper);
    if (servingMatch != null) {
      servingSize = double.tryParse(servingMatch.group(1)!);
      servingUnit = servingMatch.group(2) ?? 'g';
    }

    // Calories / Energy
    final calMatch = RegExp(
      r'(?:CALORIES|ENERGY)[:\s]+(\d+(?:\.\d+)?)\s*(?:KCAL|CAL)?',
    ).firstMatch(upper);
    if (calMatch != null) {
      calories = double.tryParse(calMatch.group(1)!);
    }

    // Carbohydrates
    final carbMatch = RegExp(
      r'(?:TOTAL\s+)?CARBOHYDRATE[S]?[:\s]+(\d+(?:\.\d+)?)\s*G?',
    ).firstMatch(upper);
    if (carbMatch != null) {
      carbs = double.tryParse(carbMatch.group(1)!);
    }

    // Sugar
    final sugarMatch = RegExp(
      r'(?:TOTAL\s+)?SUGARS?[:\s]+(\d+(?:\.\d+)?)\s*G?',
    ).firstMatch(upper);
    if (sugarMatch != null) {
      sugar = double.tryParse(sugarMatch.group(1)!);
    }

    // Added Sugar
    final addedSugarMatch = RegExp(
      r'(?:INCL\.\s+)?(?:ADDED\s+SUGARS?|ADDED\s+SUGAR)[:\s]+(\d+(?:\.\d+)?)\s*G?',
    ).firstMatch(upper);
    if (addedSugarMatch != null) {
      addedSugar = double.tryParse(addedSugarMatch.group(1)!);
    }

    // Fiber
    final fiberMatch = RegExp(
      r'(?:DIETARY\s+)?FIB(?:RE|ER)[:\s]+(\d+(?:\.\d+)?)\s*G?',
    ).firstMatch(upper);
    if (fiberMatch != null) {
      fiber = double.tryParse(fiberMatch.group(1)!);
    }

    // Protein
    final proteinMatch = RegExp(
      r'PROTEIN[:\s]+(\d+(?:\.\d+)?)\s*G?',
    ).firstMatch(upper);
    if (proteinMatch != null) {
      protein = double.tryParse(proteinMatch.group(1)!);
    }

    // Total Fat
    final fatMatch = RegExp(
      r'(?:TOTAL\s+)?FAT[:\s]+(\d+(?:\.\d+)?)\s*G?',
    ).firstMatch(upper);
    if (fatMatch != null) {
      totalFat = double.tryParse(fatMatch.group(1)!);
    }

    // Saturated Fat
    final satFatMatch = RegExp(
      r'SATURATED(?:\s+FAT)?[:\s]+(\d+(?:\.\d+)?)\s*G?',
    ).firstMatch(upper);
    if (satFatMatch != null) {
      satFat = double.tryParse(satFatMatch.group(1)!);
    }

    // Trans Fat
    final transFatMatch = RegExp(
      r'TRANS(?:\s+FAT)?[:\s]+(\d+(?:\.\d+)?)\s*G?',
    ).firstMatch(upper);
    if (transFatMatch != null) {
      transFat = double.tryParse(transFatMatch.group(1)!);
    }

    // Sodium (mg or g)
    final sodiumMatch = RegExp(
      r'SODIUM[:\s]+(\d+(?:\.\d+)?)\s*(MG|G)?',
    ).firstMatch(upper);
    if (sodiumMatch != null) {
      final val = double.tryParse(sodiumMatch.group(1)!);
      final unit = sodiumMatch.group(2) ?? 'MG';
      if (val != null) {
        // Convert grams to mg if unit is g
        sodium = unit == 'G' ? val * 1000.0 : val;
      }
    }

    return NutritionFacts(
      servingSizeValue: servingSize,
      servingSizeUnit: servingUnit,
      calories: calories,
      carbohydrates: carbs,
      sugar: sugar,
      addedSugar: addedSugar,
      dietaryFiber: fiber,
      protein: protein,
      totalFat: totalFat,
      saturatedFat: satFat,
      transFat: transFat,
      sodium: sodium,
      rawText: raw,
    );
  }

  static (String?, String?) _extractProductAndBrand(String raw) {
    final lines = raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return (null, null);

    // Usually the very top non-trivial lines are product/brand names
    String? potentialBrand;
    String? potentialProduct;

    if (lines.isNotEmpty && lines[0].length < 40 && !lines[0].contains(':')) {
      potentialBrand = lines[0];
    }
    if (lines.length > 1 && lines[1].length < 60 && !lines[1].contains(':')) {
      potentialProduct = lines[1];
    }

    return (potentialProduct ?? potentialBrand, potentialBrand);
  }
}

class ParsedPackagingData {
  final String? productName;
  final String? brand;
  final String? ingredients;
  final String? allergens;
  final NutritionFacts nutritionFacts;
  final String rawOcrText;

  const ParsedPackagingData({
    this.productName,
    this.brand,
    this.ingredients,
    this.allergens,
    required this.nutritionFacts,
    required this.rawOcrText,
  });
}
