enum AssessmentCategory {
  suitable,
  considerLimiting,
  avoid,
  incomplete,
}

class AssessmentReason {
  final String title;
  final String detail;
  final String? matchedField; // e.g., 'Allergen: Peanuts', 'Goal: Sugar'
  final bool isWarning;
  final bool isPositive;

  const AssessmentReason({
    required this.title,
    required this.detail,
    this.matchedField,
    this.isWarning = false,
    this.isPositive = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'detail': detail,
        'matchedField': matchedField,
        'isWarning': isWarning,
        'isPositive': isPositive,
      };

  factory AssessmentReason.fromJson(Map<String, dynamic> json) =>
      AssessmentReason(
        title: json['title'] as String? ?? '',
        detail: json['detail'] as String? ?? '',
        matchedField: json['matchedField'] as String?,
        isWarning: json['isWarning'] as bool? ?? false,
        isPositive: json['isPositive'] as bool? ?? false,
      );
}

class ProductAssessment {
  final AssessmentCategory category;
  final String headline;
  final List<AssessmentReason> reasons;
  final List<String> positiveHighlights;
  final List<String> uncertaintyNotes;
  final String disclaimer;

  const ProductAssessment({
    required this.category,
    required this.headline,
    this.reasons = const [],
    this.positiveHighlights = const [],
    this.uncertaintyNotes = const [],
    this.disclaimer =
        'This assessment is an informational tool based strictly on extracted label text and your selected profile. It is not medical or dietary advice. Always check physical packaging for allergens or critical health conditions.',
  });

  String get categoryDisplay {
    switch (category) {
      case AssessmentCategory.suitable:
        return 'Potentially Suitable for Your Goals';
      case AssessmentCategory.considerLimiting:
        return 'Consider Limiting / May Not Fit Goals';
      case AssessmentCategory.avoid:
        return 'Avoid / Direct Allergen or Dietary Conflict';
      case AssessmentCategory.incomplete:
        return 'Incomplete Label Data / Needs Verification';
    }
  }

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'headline': headline,
        'reasons': reasons.map((r) => r.toJson()).toList(),
        'positiveHighlights': positiveHighlights,
        'uncertaintyNotes': uncertaintyNotes,
        'disclaimer': disclaimer,
      };

  factory ProductAssessment.fromJson(Map<String, dynamic> json) {
    return ProductAssessment(
      category: AssessmentCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => AssessmentCategory.incomplete,
      ),
      headline: json['headline'] as String? ?? 'Assessment Summary',
      reasons: (json['reasons'] as List<dynamic>?)
              ?.map((r) => AssessmentReason.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      positiveHighlights: (json['positiveHighlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      uncertaintyNotes: (json['uncertaintyNotes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      disclaimer: json['disclaimer'] as String? ??
          'This assessment is an informational tool. Always inspect physical packaging.',
    );
  }
}
