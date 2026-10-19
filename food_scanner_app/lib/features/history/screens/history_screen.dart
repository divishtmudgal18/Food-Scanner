import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../assessment/screens/assessment_result_screen.dart';
import '../../assessment/models/product_assessment.dart';
import '../models/product_scan.dart';
import '../services/history_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();
    final scans = historyProvider.scans;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          if (scans.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear History',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Scan History?'),
                    content: const Text(
                      'This will delete all saved scan records from your device and cloud profile.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.avoidRed,
                        ),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  historyProvider.clearHistory();
                }
              },
            ),
        ],
      ),
      body: scans.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      size: 72,
                      color: AppColors.textMuted.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Scans Saved Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Scan food packaging labels to review ingredients, expiry dates, and personalized assessments here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: scans.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final scan = scans[index];
                return _buildScanTile(context, scan, historyProvider);
              },
            ),
    );
  }

  Widget _buildScanTile(
      BuildContext context, ProductScan scan, HistoryProvider provider) {
    Color badgeColor;
    Color badgeBg;
    String badgeText = scan.assessment.categoryDisplay;

    switch (scan.assessment.category) {
      case AssessmentCategory.suitable:
        badgeColor = AppColors.suitableGreen;
        badgeBg = AppColors.suitableGreenBg;
        break;
      case AssessmentCategory.considerLimiting:
        badgeColor = AppColors.limitingYellow;
        badgeBg = AppColors.limitingYellowBg;
        break;
      case AssessmentCategory.avoid:
        badgeColor = AppColors.avoidRed;
        badgeBg = AppColors.avoidRedBg;
        break;
      case AssessmentCategory.incomplete:
        badgeColor = AppColors.incompleteGray;
        badgeBg = AppColors.incompleteGrayBg;
        break;
    }

    return Dismissible(
      key: Key(scan.scanId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.avoidRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        provider.deleteScan(scan.scanId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${scan.productName} removed from history.'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => provider.saveScan(scan),
            ),
          ),
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AssessmentResultScreen(
                productName: scan.productName,
                brand: scan.brand,
                expiryResult: scan.expiryResult,
                nutritionFacts: scan.nutritionFacts,
                ingredientsText: scan.ingredientsText,
                allergenText: scan.allergenText,
                rawOcrText: scan.rawOcrText ?? '',
                assessment: scan.assessment,
                imagePath: scan.imageReference,
              ),
            ),
          );
        },
        child: Container(
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ),
                  Text(
                    scan.formattedScanDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                scan.productName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (scan.brand != null && scan.brand!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  scan.brand!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 14,
                    color: scan.expiryResult.parsedDate != null
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expiry: ${scan.expiryResult.formattedDate}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
