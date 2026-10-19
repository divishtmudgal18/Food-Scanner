import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../services/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<String> availablePreferences = [
    'Vegetarian',
    'Vegan',
    'Pescatarian',
    'None',
  ];

  static const List<String> availableAllergies = [
    'Peanuts',
    'Dairy / Milk',
    'Gluten / Wheat',
    'Soy',
    'Eggs',
    'Tree Nuts',
    'Fish',
    'Shellfish',
  ];

  static const List<String> availableGoals = [
    'Reduce Added Sugar',
    'Monitor Sodium / Salt',
    'Increase Protein',
    'General Balanced Eating',
  ];

  static const List<String> availableRestrictions = [
    'No Palm Oil',
    'No Artificial Sweeteners',
  ];

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Health Profile & Goals'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.email.isNotEmpty ? profile.email : 'Personalized Scan Settings',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 1: Dietary Preferences
            _buildSection(
              title: 'Dietary Preferences',
              subtitle: 'Select dietary guidelines you follow.',
              icon: Icons.eco,
              items: availablePreferences,
              selectedItems: profile.dietaryPreferences,
              onToggle: (item) => profileProvider.toggleDietaryPreference(item),
            ),
            const SizedBox(height: 20),

            // Section 2: Allergies & Intolerances
            _buildSection(
              title: 'Allergies & Intolerances',
              subtitle: 'Products containing these will trigger strict safety warnings.',
              icon: Icons.warning_amber_rounded,
              color: AppColors.avoidRed,
              items: availableAllergies,
              selectedItems: profile.allergiesAndIntolerances,
              onToggle: (item) => profileProvider.toggleAllergy(item),
            ),
            const SizedBox(height: 20),

            // Section 3: Health Goals
            _buildSection(
              title: 'Health & Nutrition Goals',
              subtitle: 'The scanner will evaluate nutrition facts against these targets.',
              icon: Icons.track_changes,
              color: AppColors.primary,
              items: availableGoals,
              selectedItems: profile.goals,
              onToggle: (item) => profileProvider.toggleGoal(item),
            ),
            const SizedBox(height: 20),

            // Section 4: Optional Restrictions
            _buildSection(
              title: 'Ingredient Preferences',
              subtitle: 'Optional specific ingredients you prefer to avoid.',
              icon: Icons.block,
              items: availableRestrictions,
              selectedItems: profile.optionalRestrictions,
              onToggle: (item) => profileProvider.toggleRestriction(item),
            ),
            const SizedBox(height: 24),

            // Privacy Disclaimer Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.incompleteGrayBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, size: 20, color: AppColors.textSecondary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Privacy Notice: Profile settings are used strictly to evaluate food labels locally and in your authenticated cloud session. No data is shared with third parties.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    Color color = AppColors.primary,
    required List<String> items,
    required List<String> selectedItems,
    required Function(String) onToggle,
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
              Icon(icon, size: 20, color: color),
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
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              final isSelected = selectedItems.contains(item);
              return FilterChip(
                label: Text(item),
                selected: isSelected,
                onSelected: (_) => onToggle(item),
                selectedColor: color.withValues(alpha: 0.15),
                checkmarkColor: color,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : AppColors.textPrimary,
                ),
                backgroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? color : AppColors.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
