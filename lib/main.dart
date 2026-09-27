import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:note_app/core/theme/app_theme.dart';
import 'package:note_app/core/theme/theme_provider.dart';
import 'package:note_app/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cruxdkboijdwglaghpwn.supabase.co',
    publishableKey: 'sb_publishable_r5uBzeAmjvVQPJkWtRHedQ_P3Po3Lbz',
  );

  final preferences = await SharedPreferences.getInstance();
  final initialThemeMode = preferences.getBool('isDarkMode') ?? false
      ? ThemeMode.dark
      : ThemeMode.light;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(initialThemeMode: initialThemeMode),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Note App',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      home: HomeScreen(),
    );
  }
}
