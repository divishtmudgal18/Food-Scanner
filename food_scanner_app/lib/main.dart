import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/profile/services/profile_provider.dart';
import 'features/history/services/history_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FoodScannerApp());
}

class FoodScannerApp extends StatelessWidget {
  const FoodScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        title: 'Food Scanner & Nutrition Evaluator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
