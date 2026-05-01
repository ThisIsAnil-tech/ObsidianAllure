import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeVariant { pink, brown }

class ThemeState {
  final ThemeMode themeMode;
  final ThemeVariant themeVariant;

  ThemeState({required this.themeMode, required this.themeVariant});

  ThemeState copyWith({ThemeMode? themeMode, ThemeVariant? themeVariant}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      themeVariant: themeVariant ?? this.themeVariant,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  final SharedPreferences prefs;

  ThemeNotifier(this.prefs) : super(_loadInitialState(prefs));

  static ThemeState _loadInitialState(SharedPreferences prefs) {
    final modeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    final variantName = prefs.getString('themeVariant') ?? ThemeVariant.pink.name;
    
    return ThemeState(
      themeMode: ThemeMode.values[modeIndex],
      themeVariant: ThemeVariant.values.firstWhere(
        (e) => e.name == variantName, 
        orElse: () => ThemeVariant.pink,
      ),
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    prefs.setInt('themeMode', mode.index);
  }

  void setThemeVariant(ThemeVariant variant) {
    state = state.copyWith(themeVariant: variant);
    prefs.setString('themeVariant', variant.name);
  }
}

// We will override this in ProviderScope after initializing SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main.dart');
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});
