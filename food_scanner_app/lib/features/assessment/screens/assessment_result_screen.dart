import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../history/models/product_scan.dart';
import '../../history/services/history_provider.dart';
import '../models/product_assessment.dart';
import '../../scan/models/expiry_date_result.dart';
import '../../scan/models/nutrition_facts.dart';

class AssessmentResultScreen extends StatefulWidget {
  final String productName;
  final String? brand;
  final ExpiryDateResult expiryResult;
  final NutritionFacts nutritionFacts;
  final String? ingredientsText;
  final String? allergenText;
  final String rawOcrText;
  final ProductAssessment assessment;
  final String? imagePath;

  const AssessmentResultScreen({
    super.key,
    required this.productName,
    this.brand,
    required this.expiryResult,
    required this.nutritionFacts,
    this.ingredientsText,
    this.allergenText,
    required this.rawOcrText,
    required this.assessment,
    this.imagePath,
  });

  @override
  State<AssessmentResultScreen> createState() => _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen> {
  bool _isSaved = false;

  void _saveScanToHistory() async {
    if (_isSaved) return;

    final scan = ProductScan(
      userId: 'demo_user_1',
      productName: widget.productName,
      brand: widget.brand,
      capturedAt: DateTime.now(),
      expiryResult: widget.expiryResult,
      nutritionFacts: widget.nutritionFacts,
      ingredientsText: widget.ingredientsText,
      allergenText: widget.allergenText,
      rawOcrText: widget.rawOcrText,
      assessment: widget.assessment,
      imageReference: widget.imagePath,
    );

    await context.read<HistoryProvider>().saveScan(scan);
    setState(() {
      _isSaved = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan saved to your history!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.assessment.category;
    final catColors = _getCategoryColors(cat);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Assessment Result'),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? AppColors.primary : null,
            ),
            tooltip: 'Save Scan',
            onPressed: _saveScanToHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Overall Assessment Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: catColors.bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: catColors.border, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(catColors.icon, color: catColors.color, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.assessment.categoryDisplay,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: catColors.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.assessment.headline,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.productName +
                        (widget.brand != null && widget.brand!.isNotEmpty
                            ? ' • ${widget.brand}'
                            : ''),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Expiry Status Card
            _buildExpiryStatusCard(),
            const SizedBox(height: 16),

            // 3. Reasons & Evidence
            if (widget.assessment.reasons.isNotEmpty) ...[
              const Text(
                'Assessment Reasons & Evidence',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ...widget.assessment.reasons.map((r) => _buildReasonCard(r)),
              const SizedBox(height: 16),
            ],

            // 4. Positive Highlights
            if (widget.assessment.positiveHighlights.isNotEmpty) ...[
              const Text(
                'Positive Attributes for Your Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: widget.assessment.positiveHighlights.map((highlight) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.suitableGreen, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              highlight,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 5. Uncertainty Notes
            if (widget.assessment.uncertaintyNotes.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.incompleteGrayBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 18, color: AppColors.textSecondary),
                        SizedBox(width: 6),
                        Text(
                          'Uncertainty & Incomplete Fields',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...widget.assessment.uncertaintyNotes.map(
                      (note) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $note',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 6. Medical Disclaimer Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.health_and_safety_outlined,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.assessment.disclaimer,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saveScanToHistory,
                    icon: Icon(_isSaved ? Icons.check : Icons.bookmark_border),
                    label: Text(_isSaved ? 'Saved' : 'Save Scan'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Done'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryStatusCard() {
    final exp = widget.expiryResult;
    final parsed = exp.parsedDate;
    final dateStr = parsed != null
        ? DateFormat('dd MMMM yyyy').format(parsed)
        : 'Date Not Available';

    Color color;
    Color bg;
    IconData icon;

    switch (exp.status) {
      case ExpiryStatus.valid:
        color = AppColors.validGreen;
        bg = AppColors.suitableGreenBg;
        icon = Icons.verified;
        break;
      case ExpiryStatus.expiringSoon:
        color = AppColors.expiringSoonAmber;
        bg = AppColors.limitingYellowBg;
        icon = Icons.access_time_filled;
        break;
      case ExpiryStatus.expired:
        color = AppColors.expiredRed;
        bg = AppColors.avoidRedBg;
        icon = Icons.cancel;
        break;
      case ExpiryStatus.unreadable:
        color = AppColors.incompleteGray;
        bg = AppColors.incompleteGrayBg;
        icon = Icons.help_outline;
        break;
    }

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, size: 20, color: color),
                  const SizedBox(width: 8),
                  const Text(
                    'Expiry / Shelf Life Check',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(
                      exp.statusDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dateStr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            exp.dateTypeDisplay,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: exp.dateType == DateType.expiry
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Important: Physical safety also depends on packaging integrity and temperature storage. Inspect the food prior to consumption.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard(AssessmentReason reason) {
    final color = reason.isWarning ? AppColors.avoidRed : AppColors.primary;
    final bg = reason.isWarning ? AppColors.avoidRedBg : AppColors.background;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              reason.isWarning ? Icons.priority_high : Icons.info,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reason.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  reason.detail,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _CategoryVisuals _getCategoryColors(AssessmentCategory cat) {
    switch (cat) {
      case AssessmentCategory.suitable:
        return _CategoryVisuals(
          color: AppColors.suitableGreen,
          bg: AppColors.suitableGreenBg,
          border: AppColors.suitableGreen.withValues(alpha: 0.4),
          icon: Icons.check_circle_outline,
        );
      case AssessmentCategory.considerLimiting:
        return _CategoryVisuals(
          color: AppColors.limitingYellow,
          bg: AppColors.limitingYellowBg,
          border: AppColors.limitingYellow.withValues(alpha: 0.4),
          icon: Icons.warning_amber_rounded,
        );
      case AssessmentCategory.avoid:
        return _CategoryVisuals(
          color: AppColors.avoidRed,
          bg: AppColors.avoidRedBg,
          border: AppColors.avoidRed.withValues(alpha: 0.4),
          icon: Icons.dangerous_outlined,
        );
      case AssessmentCategory.incomplete:
        return _CategoryVisuals(
          color: AppColors.incompleteGray,
          bg: AppColors.incompleteGrayBg,
          border: AppColors.incompleteGray.withValues(alpha: 0.4),
          icon: Icons.help_outline,
        );
    }
  }
}

class _CategoryVisuals {
  final Color color;
  final Color bg;
  final Color border;
  final IconData icon;

  _CategoryVisuals({
    required this.color,
    required this.bg,
    required this.border,
    required this.icon,
  });
}
