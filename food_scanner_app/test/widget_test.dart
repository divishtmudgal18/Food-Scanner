import 'package:flutter_test/flutter_test.dart';
import 'package:food_scanner_app/main.dart';

void main() {
  testWidgets('Renders FoodScannerApp and loads HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodScannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Food Scanner'), findsOneWidget);
    expect(find.text('Scan Product Back Label'), findsOneWidget);
  });
}
