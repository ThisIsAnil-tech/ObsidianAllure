import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/splash_screen.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    // Common TextTheme (using Quicksand for a soft, rounded aesthetic)
    final textTheme = GoogleFonts.quicksandTextTheme();

    // 1. Pink Light Theme
    final pinkLight = ThemeData(
      brightness: Brightness.light,
      textTheme: textTheme.apply(bodyColor: Colors.brown[800], displayColor: Colors.brown[900]),
      scaffoldBackgroundColor: const Color(0xFFFFF0F5), // Lavender blush
      primaryColor: const Color(0xFFFFB6C1), // Light pink
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFFB6C1),
        brightness: Brightness.light,
        primary: const Color(0xFFFF69B4), // Hot pink
        surface: Colors.white,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.pinkAccent),
        titleTextStyle: TextStyle(color: Colors.pinkAccent, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      useMaterial3: true,
    );

    // 2. Pink Dark Theme
    final pinkDark = ThemeData(
      brightness: Brightness.dark,
      textTheme: textTheme.apply(bodyColor: Colors.pink[50], displayColor: Colors.pink[100]),
      scaffoldBackgroundColor: const Color(0xFF2C1E24), // Dark muted rose
      primaryColor: const Color(0xFFC2185B),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFC2185B),
        brightness: Brightness.dark,
        primary: const Color(0xFFFF4081),
        surface: const Color(0xFF3D2A32),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF3D2A32),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFFFF4081)),
        titleTextStyle: TextStyle(color: Color(0xFFFF4081), fontSize: 20, fontWeight: FontWeight.bold),
      ),
      useMaterial3: true,
    );

    // 3. Brown Light Theme
    final brownLight = ThemeData(
      brightness: Brightness.light,
      textTheme: textTheme.apply(bodyColor: Colors.brown[900], displayColor: Colors.brown[900]),
      scaffoldBackgroundColor: const Color(0xFFFDF8F5), // Warm cream
      primaryColor: const Color(0xFFD7CCC8), // Brown 100
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8D6E63),
        brightness: Brightness.light,
        primary: const Color(0xFF795548),
        surface: Colors.white,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF795548)),
        titleTextStyle: TextStyle(color: Color(0xFF795548), fontSize: 20, fontWeight: FontWeight.bold),
      ),
      useMaterial3: true,
    );

    // 4. Brown Dark Theme
    final brownDark = ThemeData(
      brightness: Brightness.dark,
      textTheme: textTheme.apply(bodyColor: Colors.brown[100], displayColor: Colors.brown[50]),
      scaffoldBackgroundColor: const Color(0xFF2E2420), // Dark espresso
      primaryColor: const Color(0xFF5D4037),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5D4037),
        brightness: Brightness.dark,
        primary: const Color(0xFF8D6E63),
        surface: const Color(0xFF3E322C),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF3E322C),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF8D6E63)),
        titleTextStyle: TextStyle(color: Color(0xFF8D6E63), fontSize: 20, fontWeight: FontWeight.bold),
      ),
      useMaterial3: true,
    );

    ThemeData lightTheme = themeState.themeVariant == ThemeVariant.pink ? pinkLight : brownLight;
    ThemeData darkTheme = themeState.themeVariant == ThemeVariant.pink ? pinkDark : brownDark;

    return MaterialApp(
      title: 'Obsidian Allure',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeState.themeMode,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
