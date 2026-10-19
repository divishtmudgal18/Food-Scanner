class UserProfile {
  final String userId;
  final String name;
  final String email;
  final List<String> dietaryPreferences; // e.g., 'Vegetarian', 'Vegan', 'Pescatarian', 'None'
  final List<String> allergiesAndIntolerances; // e.g., 'Peanuts', 'Dairy / Milk', 'Gluten / Wheat', 'Soy', 'Eggs', 'Tree Nuts', 'Fish', 'Shellfish'
  final List<String> goals; // e.g., 'Reduce Added Sugar', 'Monitor Sodium / Salt', 'Increase Protein', 'General Balanced Eating'
  final List<String> optionalRestrictions; // e.g., 'No Artificial Sweeteners', 'No Palm Oil', 'Low Saturated Fat'
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.dietaryPreferences = const [],
    this.allergiesAndIntolerances = const [],
    this.goals = const [],
    this.optionalRestrictions = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  UserProfile copyWith({
    String? userId,
    String? name,
    String? email,
    List<String>? dietaryPreferences,
    List<String>? allergiesAndIntolerances,
    List<String>? goals,
    List<String>? optionalRestrictions,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      allergiesAndIntolerances:
          allergiesAndIntolerances ?? this.allergiesAndIntolerances,
      goals: goals ?? this.goals,
      optionalRestrictions:
          optionalRestrictions ?? this.optionalRestrictions,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'dietaryPreferences': dietaryPreferences,
      'allergiesAndIntolerances': allergiesAndIntolerances,
      'goals': goals,
      'optionalRestrictions': optionalRestrictions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String? ?? 'guest_user',
      name: json['name'] as String? ?? 'Guest User',
      email: json['email'] as String? ?? '',
      dietaryPreferences: (json['dietaryPreferences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      allergiesAndIntolerances:
          (json['allergiesAndIntolerances'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
      goals: (json['goals'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      optionalRestrictions:
          (json['optionalRestrictions'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static UserProfile defaultProfile({String userId = 'demo_user_1'}) {
    return UserProfile(
      userId: userId,
      name: 'Demo Student',
      email: 'demo@cloudproject.edu',
      dietaryPreferences: ['Vegetarian'],
      allergiesAndIntolerances: ['Peanuts'],
      goals: ['Reduce Added Sugar', 'Monitor Sodium / Salt'],
      optionalRestrictions: ['No Palm Oil'],
    );
  }
}
