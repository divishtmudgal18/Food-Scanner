import '../scan/models/expiry_date_result.dart';

class ExpiryParser {
  static const Map<String, int> _months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
    'january': 1,
    'february': 2,
    'march': 3,
    'april': 4,
    'june': 6,
    'july': 7,
    'august': 8,
    'september': 9,
    'october': 10,
    'november': 11,
    'december': 12,
  };

  /// Parses raw OCR text and attempts to extract and classify the expiry date.
  /// [referenceDate] defaults to DateTime.now() if not provided, allowing deterministic unit testing.
  static ExpiryDateResult parse(String ocrText, {DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (ocrText.trim().isEmpty) {
      return const ExpiryDateResult(
        status: ExpiryStatus.unreadable,
        ambiguityReason: 'OCR text is empty.',
      );
    }

    final lines = ocrText.split('\n');

    // Strategy 1: Look for targeted date labels on the same or next line
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineUpper = line.toUpperCase();

      DateType detectedType = _detectDateType(lineUpper);

      if (detectedType != DateType.unknown) {
        // First search within the current line
        var dateCandidate = _extractDateFromLine(line, detectedType, today);
        if (dateCandidate != null) {
          return dateCandidate;
        }

        // Sometimes the date is printed on the immediate next line (e.g. "USE BY\n15/12/2026")
        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1];
          dateCandidate = _extractDateFromLine(nextLine, detectedType, today);
          if (dateCandidate != null) {
            return dateCandidate;
          }
        }
      }
    }

    // Strategy 2: Fallback scan through all lines for any valid date pattern even without a direct prefix
    for (final line in lines) {
      final dateCandidate = _extractDateFromLine(line, DateType.unknown, today);
      if (dateCandidate != null) {
        return dateCandidate;
      }
    }

    return const ExpiryDateResult(
      status: ExpiryStatus.unreadable,
      ambiguityReason: 'No recognized date pattern found on the label.',
      confidence: 0.0,
    );
  }

  static DateType _detectDateType(String textUpper) {
    if (textUpper.contains('USE BY') ||
        textUpper.contains('USE-BY') ||
        textUpper.contains('USEBY') ||
        textUpper.contains('EXPIRY') ||
        textUpper.contains('EXP.') ||
        textUpper.contains('EXP DATE') ||
        textUpper.contains('EXPIRES') ||
        textUpper.contains('EXP:')) {
      return DateType.expiry;
    }
    if (textUpper.contains('BEST BEFORE') ||
        textUpper.contains('BEST-BEFORE') ||
        textUpper.contains('BEST BY') ||
        textUpper.contains('BEST-BY') ||
        textUpper.contains('BBD') ||
        textUpper.contains('BB:')) {
      return DateType.bestBefore;
    }
    if (textUpper.contains('MFG') ||
        textUpper.contains('MFD') ||
        textUpper.contains('PKD') ||
        textUpper.contains('PACKED')) {
      return DateType.manufacturing;
    }
    return DateType.unknown;
  }

  static ExpiryDateResult? _extractDateFromLine(
      String line, DateType dateType, DateTime today) {
    // Pattern 1: Day with Named Month (e.g., "15 OCT 2026", "24-Dec-2025", "5 Mar 26")
    final namedMonthRegex = RegExp(
      r'\b(\d{1,2})[\s\-\./]([A-Za-z]{3,9})[\s\-\./](\d{2,4})\b',
    );
    final namedMatch = namedMonthRegex.firstMatch(line);
    if (namedMatch != null) {
      final dayStr = namedMatch.group(1)!;
      final monthStr = namedMatch.group(2)!.toLowerCase();
      final yearStr = namedMatch.group(3)!;

      final month = _months[monthStr];
      final day = int.tryParse(dayStr);
      final year = _normalizeYear(int.tryParse(yearStr) ?? 0);

      if (month != null && day != null && day >= 1 && day <= 31 && year > 2000) {
        final parsedDate = DateTime(year, month, day);
        return _buildResult(
          parsedDate: parsedDate,
          rawDateString: namedMatch.group(0),
          dateType: dateType,
          needsConfirmation: false,
          ambiguityReason: null,
          today: today,
          confidence: 0.95,
        );
      }
    }

    // Pattern 2: Month with Named Month only (e.g. "OCT 2026", "DEC/25")
    final monthYearNamedRegex = RegExp(
      r'\b([A-Za-z]{3,9})[\s\-\./](\d{2,4})\b',
    );
    final monthYearNamedMatch = monthYearNamedRegex.firstMatch(line);
    if (monthYearNamedMatch != null) {
      final monthStr = monthYearNamedMatch.group(1)!.toLowerCase();
      final yearStr = monthYearNamedMatch.group(2)!;
      final month = _months[monthStr];
      final year = _normalizeYear(int.tryParse(yearStr) ?? 0);

      if (month != null && year > 2000) {
        // Set to last day of that month for expiry
        final lastDay = _daysInMonth(year, month);
        final parsedDate = DateTime(year, month, lastDay);
        return _buildResult(
          parsedDate: parsedDate,
          rawDateString: monthYearNamedMatch.group(0),
          dateType: dateType,
          needsConfirmation: false,
          ambiguityReason: 'Month/Year only detected (end of month assumed).',
          today: today,
          confidence: 0.85,
        );
      }
    }

    // Pattern 3: Standard numeric (e.g. "15/10/2026", "15-10-26", "2026-10-15")
    // ISO format: YYYY-MM-DD
    final isoRegex = RegExp(r'\b(20\d{2})[./\-](\d{1,2})[./\-](\d{1,2})\b');
    final isoMatch = isoRegex.firstMatch(line);
    if (isoMatch != null) {
      final year = int.parse(isoMatch.group(1)!);
      final month = int.parse(isoMatch.group(2)!);
      final day = int.parse(isoMatch.group(3)!);
      if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
        final parsedDate = DateTime(year, month, day);
        return _buildResult(
          parsedDate: parsedDate,
          rawDateString: isoMatch.group(0),
          dateType: dateType,
          needsConfirmation: false,
          ambiguityReason: null,
          today: today,
          confidence: 0.90,
        );
      }
    }

    // General DD/MM/YYYY or MM/DD/YYYY
    final numRegex = RegExp(r'\b(\d{1,2})[./\-](\d{1,2})[./\-](\d{2,4})\b');
    final numMatch = numRegex.firstMatch(line);
    if (numMatch != null) {
      final p1 = int.parse(numMatch.group(1)!);
      final p2 = int.parse(numMatch.group(2)!);
      final year = _normalizeYear(int.parse(numMatch.group(3)!));

      if (year > 2000) {
        // Check for unambiguous cases
        if (p1 > 12 && p2 <= 12) {
          // Unambiguous DD/MM/YYYY
          final parsedDate = DateTime(year, p2, p1);
          return _buildResult(
            parsedDate: parsedDate,
            rawDateString: numMatch.group(0),
            dateType: dateType,
            needsConfirmation: false,
            ambiguityReason: null,
            today: today,
            confidence: 0.90,
          );
        } else if (p2 > 12 && p1 <= 12) {
          // Unambiguous MM/DD/YYYY
          final parsedDate = DateTime(year, p1, p2);
          return _buildResult(
            parsedDate: parsedDate,
            rawDateString: numMatch.group(0),
            dateType: dateType,
            needsConfirmation: false,
            ambiguityReason: null,
            today: today,
            confidence: 0.90,
          );
        } else if (p1 <= 12 && p2 <= 12 && p1 != p2) {
          // Ambiguous! Could be DD/MM or MM/DD
          // Default to international DD/MM/YYYY but flag needsConfirmation
          final assumedDate = DateTime(year, p2, p1);
          return _buildResult(
            parsedDate: assumedDate,
            rawDateString: numMatch.group(0),
            dateType: dateType,
            needsConfirmation: true,
            ambiguityReason:
                'Ambiguous date format: Could be $p1/$p2/$year or $p2/$p1/$year. Please confirm.',
            today: today,
            confidence: 0.65,
          );
        } else if (p1 == p2 && p1 <= 12) {
          // Day and month are identical (e.g. 05/05/2026) -> no ambiguity
          final parsedDate = DateTime(year, p1, p1);
          return _buildResult(
            parsedDate: parsedDate,
            rawDateString: numMatch.group(0),
            dateType: dateType,
            needsConfirmation: false,
            ambiguityReason: null,
            today: today,
            confidence: 0.90,
          );
        }
      }
    }

    // Pattern 4: MM/YYYY or MM/YY (Month + Year only)
    final numMonthYearRegex = RegExp(r'\b(\d{1,2})[./\-](\d{2,4})\b');
    final numMonthYearMatch = numMonthYearRegex.firstMatch(line);
    if (numMonthYearMatch != null) {
      final month = int.parse(numMonthYearMatch.group(1)!);
      final year = _normalizeYear(int.parse(numMonthYearMatch.group(2)!));
      if (month >= 1 && month <= 12 && year > 2000) {
        final lastDay = _daysInMonth(year, month);
        final parsedDate = DateTime(year, month, lastDay);
        return _buildResult(
          parsedDate: parsedDate,
          rawDateString: numMonthYearMatch.group(0),
          dateType: dateType,
          needsConfirmation: true,
          ambiguityReason: 'Only Month/Year was detected; end of month was assumed.',
          today: today,
          confidence: 0.70,
        );
      }
    }

    return null;
  }

  static ExpiryDateResult _buildResult({
    required DateTime parsedDate,
    required String? rawDateString,
    required DateType dateType,
    required bool needsConfirmation,
    required String? ambiguityReason,
    required DateTime today,
    required double confidence,
  }) {
    ExpiryStatus status;
    final normalizedDate =
        DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

    if (normalizedDate.isBefore(today)) {
      status = ExpiryStatus.expired;
    } else {
      final daysLeft = normalizedDate.difference(today).inDays;
      if (daysLeft <= 7) {
        status = ExpiryStatus.expiringSoon;
      } else {
        status = ExpiryStatus.valid;
      }
    }

    return ExpiryDateResult(
      parsedDate: parsedDate,
      rawDateString: rawDateString,
      dateType: dateType,
      status: status,
      needsConfirmation: needsConfirmation,
      ambiguityReason: ambiguityReason,
      confidence: confidence,
    );
  }

  static int _normalizeYear(int year) {
    if (year < 100) {
      return 2000 + year;
    }
    return year;
  }

  static int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
