import 'package:flutter_test/flutter_test.dart';
import 'package:food_scanner_app/features/scan/models/expiry_date_result.dart';
import 'package:food_scanner_app/features/parsing/expiry_parser.dart';

void main() {
  final referenceDate = DateTime(2026, 10, 20); // Test reference date

  group('ExpiryParser Unit Tests', () {
    test('Correctly extracts unambiguous DD/MM/YYYY with USE BY', () {
      const ocrText = '''
        NESTLE CHOCOLATE BAR
        BATCH NO: 849302
        USE BY 28/11/2026
        NET WT: 150g
      ''';

      final result =
          ExpiryParser.parse(ocrText, referenceDate: referenceDate);

      expect(result.status, equals(ExpiryStatus.valid));
      expect(result.dateType, equals(DateType.expiry));
      expect(result.parsedDate, equals(DateTime(2026, 11, 28)));
      expect(result.needsConfirmation, isFalse);
    });

    test('Correctly extracts named month with BEST BEFORE', () {
      const ocrText = '''
        OAT CRUNCH BISCUITS
        BEST BEFORE 15-OCT-2027
        KEEP IN A COOL DRY PLACE
      ''';

      final result =
          ExpiryParser.parse(ocrText, referenceDate: referenceDate);

      expect(result.status, equals(ExpiryStatus.valid));
      expect(result.dateType, equals(DateType.bestBefore));
      expect(result.parsedDate, equals(DateTime(2027, 10, 15)));
      expect(result.needsConfirmation, isFalse);
    });

    test('Identifies and flags ambiguous numeric dates (e.g. 05/06/2026)', () {
      const ocrText = '''
        SPICY TORTILLA CHIPS
        EXP: 05/06/2026
      ''';

      final result =
          ExpiryParser.parse(ocrText, referenceDate: referenceDate);

      expect(result.dateType, equals(DateType.expiry));
      expect(result.needsConfirmation, isTrue);
      expect(result.ambiguityReason, contains('Ambiguous date format'));
    });

    test('Correctly detects expired products', () {
      const ocrText = '''
        FRESH PASTEURIZED MILK
        USE BY: 10/05/2024
      ''';

      final result =
          ExpiryParser.parse(ocrText, referenceDate: referenceDate);

      expect(result.status, equals(ExpiryStatus.expired));
      expect(result.parsedDate, equals(DateTime(2024, 5, 10)));
    });

    test('Correctly detects products expiring soon (within 7 days)', () {
      const ocrText = '''
        FRESH YOGURT
        USE BY 23/10/2026
      '''; // 3 days after referenceDate (20 Oct 2026)

      final result =
          ExpiryParser.parse(ocrText, referenceDate: referenceDate);

      expect(result.status, equals(ExpiryStatus.expiringSoon));
    });

    test('Handles month-and-year only dates (e.g. BB: 12/2027)', () {
      const ocrText = '''
        CANNED CRUSHED TOMATOES
        BEST BEFORE 12/2027
      ''';

      final result =
          ExpiryParser.parse(ocrText, referenceDate: referenceDate);

      expect(result.status, equals(ExpiryStatus.valid));
      expect(result.dateType, equals(DateType.bestBefore));
      expect(result.parsedDate, equals(DateTime(2027, 12, 31)));
      expect(result.needsConfirmation, isTrue);
    });

    test('Gracefully returns unreadable when no date pattern exists', () {
      const ocrText = '''
        SUPER CRUNCHY CHIPS
        INGREDIENTS: POTATOES, SUNFLOWER OIL, SALT.
        STORE IN A COOL DRY PLACE.
      ''';

      final result =
          ExpiryParser.parse(ocrText, referenceDate: referenceDate);

      expect(result.status, equals(ExpiryStatus.unreadable));
      expect(result.parsedDate, isNull);
    });
  });
}
