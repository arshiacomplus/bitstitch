import 'package:flutter/material.dart';
import 'features/home/ui/home_screen.dart';

void main() {
  runApp(const BitStitchApp());
}

class BitStitchApp extends StatelessWidget {
  const BitStitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BitStitch',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}