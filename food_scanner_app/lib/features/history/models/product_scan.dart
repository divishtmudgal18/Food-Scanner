import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../scan/models/nutrition_facts.dart';
import '../../scan/models/expiry_date_result.dart';
import '../../assessment/models/product_assessment.dart';

class ProductScan {
  final String scanId;
  final String userId;
  final String productName;
  final String? brand;
  final DateTime capturedAt;
  final ExpiryDateResult expiryResult;
  final NutritionFacts nutritionFacts;
  final String? ingredientsText;
  final String? allergenText;
  final String? rawOcrText;
  final ProductAssessment assessment;
  final String? imageReference; // Optional local path or cloud S3 URL

  ProductScan({
    String? scanId,
    required this.userId,
    this.productName = 'Packaged Food Product',
    this.brand,
    DateTime? capturedAt,
    required this.expiryResult,
    this.nutritionFacts = const NutritionFacts(),
    this.ingredientsText,
    this.allergenText,
    this.rawOcrText,
    required this.assessment,
    this.imageReference,
  })  : scanId = scanId ?? const Uuid().v4(),
        capturedAt = capturedAt ?? DateTime.now();

  String get formattedScanDate =>
      DateFormat('dd MMM yyyy, hh:mm a').format(capturedAt);

  Map<String, dynamic> toJson() {
    return {
      'scanId': scanId,
      'userId': userId,
      'productName': productName,
      'brand': brand,
      'capturedAt': capturedAt.toIso8601String(),
      'expiryResult': expiryResult.toJson(),
      'nutritionFacts': nutritionFacts.toJson(),
      'ingredientsText': ingredientsText,
      'allergenText': allergenText,
      'rawOcrText': rawOcrText,
      'assessment': assessment.toJson(),
      'imageReference': imageReference,
    };
  }

  factory ProductScan.fromJson(Map<String, dynamic> json) {
    return ProductScan(
      scanId: json['scanId'] as String? ?? const Uuid().v4(),
      userId: json['userId'] as String? ?? 'guest_user',
      productName: json['productName'] as String? ?? 'Packaged Food Product',
      brand: json['brand'] as String?,
      capturedAt: json['capturedAt'] != null
          ? DateTime.tryParse(json['capturedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      expiryResult: json['expiryResult'] != null
          ? ExpiryDateResult.fromJson(
              json['expiryResult'] as Map<String, dynamic>)
          : const ExpiryDateResult(),
      nutritionFacts: json['nutritionFacts'] != null
          ? NutritionFacts.fromJson(
              json['nutritionFacts'] as Map<String, dynamic>)
          : const NutritionFacts(),
      ingredientsText: json['ingredientsText'] as String?,
      allergenText: json['allergenText'] as String?,
      rawOcrText: json['rawOcrText'] as String?,
      assessment: json['assessment'] != null
          ? ProductAssessment.fromJson(
              json['assessment'] as Map<String, dynamic>)
          : const ProductAssessment(
              category: AssessmentCategory.incomplete,
              headline: 'Incomplete scan data',
            ),
      imageReference: json['imageReference'] as String?,
    );
  }
}
