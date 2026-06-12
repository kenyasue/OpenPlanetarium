import 'package:flutter/material.dart';

import 'presentation/screens/sky/sky_screen.dart';

/// Root widget. Fixed dark theme (docs/product-requirements.md design quality).
class PlanetariumApp extends StatelessWidget {
  const PlanetariumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenPlanetarium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF53C8E8), // Accent: cyan tones
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF04060E),
      ),
      home: const SkyScreen(),
    );
  }
}
