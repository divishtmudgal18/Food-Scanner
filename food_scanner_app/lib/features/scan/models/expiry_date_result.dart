import 'package:intl/intl.dart';

enum DateType {
  expiry, // Safety threshold: "Use By", "Expiry Date", "EXP"
  bestBefore, // Quality threshold: "Best Before", "Best By", "BBD"
  manufacturing, // Production date: "MFG", "PKD"
  unknown,
}

enum ExpiryStatus {
  valid,
  expiringSoon, // Within 7 days
  expired,
  unreadable,
}

class ExpiryDateResult {
  final DateTime? parsedDate;
  final String? rawDateString;
  final DateType dateType;
  final ExpiryStatus status;
  final bool needsConfirmation;
  final String? ambiguityReason;
  final double confidence; // 0.0 to 1.0

  const ExpiryDateResult({
    this.parsedDate,
    this.rawDateString,
    this.dateType = DateType.unknown,
    this.status = ExpiryStatus.unreadable,
    this.needsConfirmation = false,
    this.ambiguityReason,
    this.confidence = 0.0,
  });

  String get dateTypeDisplay {
    switch (dateType) {
      case DateType.expiry:
        return 'Expiry / Use By (Food Safety Boundary)';
      case DateType.bestBefore:
        return 'Best Before (Quality Boundary)';
      case DateType.manufacturing:
        return 'Manufacturing / Packaged Date';
      case DateType.unknown:
        return 'Date Label Unspecified';
    }
  }

  String get statusDisplay {
    switch (status) {
      case ExpiryStatus.valid:
        return 'Valid / Within Date';
      case ExpiryStatus.expiringSoon:
        return 'Expiring Soon (Within 7 Days)';
      case ExpiryStatus.expired:
        return 'Past Printed Date (Expired)';
      case ExpiryStatus.unreadable:
        return 'No Legible Date Found';
    }
  }

  String get formattedDate {
    if (parsedDate == null) return 'Not Detected';
    return DateFormat('dd MMM yyyy').format(parsedDate!);
  }

  ExpiryDateResult copyWith({
    DateTime? parsedDate,
    String? rawDateString,
    DateType? dateType,
    ExpiryStatus? status,
    bool? needsConfirmation,
    String? ambiguityReason,
    double? confidence,
  }) {
    return ExpiryDateResult(
      parsedDate: parsedDate ?? this.parsedDate,
      rawDateString: rawDateString ?? this.rawDateString,
      dateType: dateType ?? this.dateType,
      status: status ?? this.status,
      needsConfirmation: needsConfirmation ?? this.needsConfirmation,
      ambiguityReason: ambiguityReason ?? this.ambiguityReason,
      confidence: confidence ?? this.confidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parsedDate': parsedDate?.toIso8601String(),
      'rawDateString': rawDateString,
      'dateType': dateType.name,
      'status': status.name,
      'needsConfirmation': needsConfirmation,
      'ambiguityReason': ambiguityReason,
      'confidence': confidence,
    };
  }

  factory ExpiryDateResult.fromJson(Map<String, dynamic> json) {
    return ExpiryDateResult(
      parsedDate: json['parsedDate'] != null
          ? DateTime.tryParse(json['parsedDate'] as String)
          : null,
      rawDateString: json['rawDateString'] as String?,
      dateType: DateType.values.firstWhere(
        (e) => e.name == json['dateType'],
        orElse: () => DateType.unknown,
      ),
      status: ExpiryStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ExpiryStatus.unreadable,
      ),
      needsConfirmation: json['needsConfirmation'] as bool? ?? false,
      ambiguityReason: json['ambiguityReason'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
