import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:note_app/screens/home_screen.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://cruxdkboijdwglaghpwn.supabase.co',
    publishableKey: 'sb_publishable_r5uBzeAmjvVQPJkWtRHedQ_P3Po3Lbz',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Note App',
      home: HomeScreen(),
    );
  }
}
