import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../assessment/screens/assessment_result_screen.dart';
import '../../assessment/services/assessment_engine.dart';
import '../../profile/services/profile_provider.dart';
import '../models/expiry_date_result.dart';
import '../models/nutrition_facts.dart';
import '../services/ocr_scanner_service.dart';

class ReviewAndEditScreen extends StatefulWidget {
  final ScanExtractionResult extraction;

  const ReviewAndEditScreen({super.key, required this.extraction});

  @override
  State<ReviewAndEditScreen> createState() => _ReviewAndEditScreenState();
}

class _ReviewAndEditScreenState extends State<ReviewAndEditScreen> {
  late TextEditingController _productNameController;
  late TextEditingController _brandController;
  late TextEditingController _ingredientsController;
  late TextEditingController _allergensController;

  late TextEditingController _caloriesController;
  late TextEditingController _sugarController;
  late TextEditingController _sodiumController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  DateTime? _selectedDate;
  DateType _selectedDateType = DateType.unknown;
  bool _needsConfirmation = false;
  String? _ambiguityReason;

  @override
  void initState() {
    super.initState();
    final ext = widget.extraction;
    _productNameController = TextEditingController(text: ext.productName);
    _brandController = TextEditingController(text: ext.brand ?? '');
    _ingredientsController = TextEditingController(text: ext.ingredients ?? '');
    _allergensController = TextEditingController(text: ext.allergens ?? '');

    _caloriesController = TextEditingController(
      text: ext.nutritionFacts.calories != null
          ? ext.nutritionFacts.calories!.toStringAsFixed(0)
          : '',
    );
    _sugarController = TextEditingController(
      text: ext.nutritionFacts.sugar != null
          ? ext.nutritionFacts.sugar!.toString()
          : '',
    );
    _sodiumController = TextEditingController(
      text: ext.nutritionFacts.sodium != null
          ? ext.nutritionFacts.sodium!.toStringAsFixed(0)
          : '',
    );
    _proteinController = TextEditingController(
      text: ext.nutritionFacts.protein != null
          ? ext.nutritionFacts.protein!.toString()
          : '',
    );
    _carbsController = TextEditingController(
      text: ext.nutritionFacts.carbohydrates != null
          ? ext.nutritionFacts.carbohydrates!.toString()
          : '',
    );
    _fatController = TextEditingController(
      text: ext.nutritionFacts.totalFat != null
          ? ext.nutritionFacts.totalFat!.toString()
          : '',
    );

    _selectedDate = ext.expiryResult.parsedDate;
    _selectedDateType = ext.expiryResult.dateType;
    _needsConfirmation = ext.expiryResult.needsConfirmation;
    _ambiguityReason = ext.expiryResult.ambiguityReason;
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _brandController.dispose();
    _ingredientsController.dispose();
    _allergensController.dispose();
    _caloriesController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'SELECT CORRECT EXPIRY / BEST-BEFORE DATE',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _needsConfirmation = false;
        _ambiguityReason = null;
      });
    }
  }

  void _proceedToAssessment() {
    final profile = context.read<ProfileProvider>().profile;

    // Recalculate expiry result status with the confirmed/edited date
    final today = DateTime.now();
    final dateOnlyToday = DateTime(today.year, today.month, today.day);

    ExpiryStatus status = ExpiryStatus.unreadable;
    if (_selectedDate != null) {
      final norm = DateTime(
          _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      if (norm.isBefore(dateOnlyToday)) {
        status = ExpiryStatus.expired;
      } else {
        final days = norm.difference(dateOnlyToday).inDays;
        status = days <= 7 ? ExpiryStatus.expiringSoon : ExpiryStatus.valid;
      }
    }

    final confirmedExpiryResult = ExpiryDateResult(
      parsedDate: _selectedDate,
      rawDateString: _selectedDate != null
          ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
          : null,
      dateType: _selectedDateType,
      status: status,
      needsConfirmation: false,
      confidence: 1.0, // Confirmed by user
    );

    final confirmedNutrition = NutritionFacts(
      calories: double.tryParse(_caloriesController.text.trim()),
      sugar: double.tryParse(_sugarController.text.trim()),
      sodium: double.tryParse(_sodiumController.text.trim()),
      protein: double.tryParse(_proteinController.text.trim()),
      carbohydrates: double.tryParse(_carbsController.text.trim()),
      totalFat: double.tryParse(_fatController.text.trim()),
      rawText: widget.extraction.rawText,
    );

    final assessment = AssessmentEngine.evaluate(
      profile: profile,
      nutrition: confirmedNutrition,
      ingredientsText: _ingredientsController.text.trim(),
      allergenText: _allergensController.text.trim(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssessmentResultScreen(
          productName: _productNameController.text.trim().isNotEmpty
              ? _productNameController.text.trim()
              : 'Packaged Food Product',
          brand: _brandController.text.trim().isNotEmpty
              ? _brandController.text.trim()
              : null,
          expiryResult: confirmedExpiryResult,
          nutritionFacts: confirmedNutrition,
          ingredientsText: _ingredientsController.text.trim().isNotEmpty
              ? _ingredientsController.text.trim()
              : null,
          allergenText: _allergensController.text.trim().isNotEmpty
              ? _allergensController.text.trim()
              : null,
          rawOcrText: widget.extraction.rawText,
          assessment: assessment,
          imagePath: widget.extraction.imagePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Verify Label OCR'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instruction Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Please verify the detected information. OCR can make mistakes on dates and small ingredient fonts.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Expiry Date Verification Card (Highest Priority)
            _buildExpiryVerificationCard(),
            const SizedBox(height: 16),

            // Product Details Card
            _buildCard(
              title: 'Product Information',
              icon: Icons.label_outline,
              child: Column(
                children: [
                  TextField(
                    controller: _productNameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: 'Brand / Manufacturer',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nutrition Facts Grid
            _buildCard(
              title: 'Nutrition Facts (Per Serving)',
              icon: Icons.restaurant,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _sugarController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Sugars (g)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _sodiumController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Sodium (mg)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _proteinController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Protein (g)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _caloriesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Calories (kcal)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _carbsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Carbohydrates (g)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _fatController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total Fat (g)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ingredients & Allergens
            _buildCard(
              title: 'Ingredients & Allergen Statement',
              icon: Icons.list_alt,
              child: Column(
                children: [
                  TextField(
                    controller: _allergensController,
                    decoration: const InputDecoration(
                      labelText: 'Allergen Statement (e.g. Contains Milk, Soy)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ingredientsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Ingredients List',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Proceed Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _proceedToAssessment,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text(
                  'Evaluate Food with My Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryVerificationCard() {
    final hasDate = _selectedDate != null;
    final formatted = hasDate
        ? DateFormat('dd MMMM yyyy').format(_selectedDate!)
        : 'No date detected';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _needsConfirmation ? AppColors.expiringSoonAmber : AppColors.border,
          width: _needsConfirmation ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Expiry & Best-Before Date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.edit_calendar, size: 16),
                label: const Text('Change Date'),
              ),
            ],
          ),
          if (_needsConfirmation && _ambiguityReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.limitingYellowBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.limitingYellow, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _ambiguityReason!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.limitingYellow,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Date display box
          InkWell(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    hasDate ? Icons.event_available : Icons.event_busy,
                    color: hasDate ? AppColors.validGreen : AppColors.expiredRed,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasDate ? 'Detected Date' : 'Missing Expiry Date',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        Text(
                          formatted,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Date Type Selector: Expiry vs Best Before
          const Text(
            'Date Classification:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SegmentedButton<DateType>(
            segments: const [
              ButtonSegment(
                value: DateType.expiry,
                label: Text('Use By / Expiry'),
                icon: Icon(Icons.security, size: 16),
              ),
              ButtonSegment(
                value: DateType.bestBefore,
                label: Text('Best Before'),
                icon: Icon(Icons.verified, size: 16),
              ),
            ],
            selected: {_selectedDateType == DateType.bestBefore ? DateType.bestBefore : DateType.expiry},
            onSelectionChanged: (set) {
              setState(() {
                _selectedDateType = set.first;
              });
            },
          ),
          const SizedBox(height: 6),
          Text(
            _selectedDateType == DateType.bestBefore
                ? 'Note: "Best Before" relates to food quality, taste, and freshness rather than safety.'
                : 'Note: "Use By / Expiry" is a strict food safety threshold. Do not consume past this date.',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
