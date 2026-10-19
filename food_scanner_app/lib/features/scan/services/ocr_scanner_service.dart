import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../models/expiry_date_result.dart';
import '../models/nutrition_facts.dart';
import '../../parsing/expiry_parser.dart';
import '../../parsing/nutrition_parser.dart';

class ScanExtractionResult {
  final String rawText;
  final String? productName;
  final String? brand;
  final ExpiryDateResult expiryResult;
  final NutritionFacts nutritionFacts;
  final String? ingredients;
  final String? allergens;
  final String? imagePath;

  const ScanExtractionResult({
    required this.rawText,
    this.productName,
    this.brand,
    required this.expiryResult,
    required this.nutritionFacts,
    this.ingredients,
    this.allergens,
    this.imagePath,
  });
}

class OcrScannerService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Pick an image from gallery or capture via camera and extract text via Google ML Kit
  Future<ScanExtractionResult?> processImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (file == null) return null;

    final inputImage = InputImage.fromFile(File(file.path));
    final recognizedText = await _textRecognizer.processImage(inputImage);
    final rawText = recognizedText.text;

    return parseRawOcr(rawText, imagePath: file.path);
  }

  /// Parses raw text directly (usable for camera OCR as well as instant test samples)
  ScanExtractionResult parseRawOcr(String rawText, {String? imagePath}) {
    final expiryResult = ExpiryParser.parse(rawText);
    final parsedData = NutritionParser.parse(rawText);

    return ScanExtractionResult(
      rawText: rawText,
      productName: parsedData.productName ?? 'Scanned Food Item',
      brand: parsedData.brand,
      expiryResult: expiryResult,
      nutritionFacts: parsedData.nutritionFacts,
      ingredients: parsedData.ingredients,
      allergens: parsedData.allergens,
      imagePath: imagePath,
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}
