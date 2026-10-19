class NutritionFacts {
  final double? servingSizeValue;
  final String? servingSizeUnit; // e.g., 'g', 'ml', 'piece'
  final double? calories; // kcal
  final double? carbohydrates; // g
  final double? sugar; // g
  final double? addedSugar; // g
  final double? dietaryFiber; // g
  final double? protein; // g
  final double? totalFat; // g
  final double? saturatedFat; // g
  final double? transFat; // g
  final double? sodium; // mg
  final double? cholesterol; // mg
  final String? rawText; // Original OCR segment for nutrition table

  const NutritionFacts({
    this.servingSizeValue,
    this.servingSizeUnit,
    this.calories,
    this.carbohydrates,
    this.sugar,
    this.addedSugar,
    this.dietaryFiber,
    this.protein,
    this.totalFat,
    this.saturatedFat,
    this.transFat,
    this.sodium,
    this.cholesterol,
    this.rawText,
  });

  bool get isEmpty =>
      calories == null &&
      sugar == null &&
      sodium == null &&
      protein == null &&
      totalFat == null &&
      carbohydrates == null;

  NutritionFacts copyWith({
    double? servingSizeValue,
    String? servingSizeUnit,
    double? calories,
    double? carbohydrates,
    double? sugar,
    double? addedSugar,
    double? dietaryFiber,
    double? protein,
    double? totalFat,
    double? saturatedFat,
    double? transFat,
    double? sodium,
    double? cholesterol,
    String? rawText,
  }) {
    return NutritionFacts(
      servingSizeValue: servingSizeValue ?? this.servingSizeValue,
      servingSizeUnit: servingSizeUnit ?? this.servingSizeUnit,
      calories: calories ?? this.calories,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      sugar: sugar ?? this.sugar,
      addedSugar: addedSugar ?? this.addedSugar,
      dietaryFiber: dietaryFiber ?? this.dietaryFiber,
      protein: protein ?? this.protein,
      totalFat: totalFat ?? this.totalFat,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      transFat: transFat ?? this.transFat,
      sodium: sodium ?? this.sodium,
      cholesterol: cholesterol ?? this.cholesterol,
      rawText: rawText ?? this.rawText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'servingSizeValue': servingSizeValue,
      'servingSizeUnit': servingSizeUnit,
      'calories': calories,
      'carbohydrates': carbohydrates,
      'sugar': sugar,
      'addedSugar': addedSugar,
      'dietaryFiber': dietaryFiber,
      'protein': protein,
      'totalFat': totalFat,
      'saturatedFat': saturatedFat,
      'transFat': transFat,
      'sodium': sodium,
      'cholesterol': cholesterol,
      'rawText': rawText,
    };
  }

  factory NutritionFacts.fromJson(Map<String, dynamic> json) {
    return NutritionFacts(
      servingSizeValue: (json['servingSizeValue'] as num?)?.toDouble(),
      servingSizeUnit: json['servingSizeUnit'] as String?,
      calories: (json['calories'] as num?)?.toDouble(),
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
      addedSugar: (json['addedSugar'] as num?)?.toDouble(),
      dietaryFiber: (json['dietaryFiber'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      totalFat: (json['totalFat'] as num?)?.toDouble(),
      saturatedFat: (json['saturatedFat'] as num?)?.toDouble(),
      transFat: (json['transFat'] as num?)?.toDouble(),
      sodium: (json['sodium'] as num?)?.toDouble(),
      cholesterol: (json['cholesterol'] as num?)?.toDouble(),
      rawText: json['rawText'] as String?,
    );
  }
}
