import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  static const _key = 'liked_nodes';
  SharedPreferences? _prefs;

  Future<void> _loadFavorites() async {
    _prefs ??= await SharedPreferences.getInstance();
    final likedList = _prefs!.getStringList(_key) ?? [];
    state = likedList.toSet();
  }

  Future<void> toggleFavorite(String nodeId) async {
    _prefs ??= await SharedPreferences.getInstance();
    final newSet = Set<String>.from(state);
    
    if (newSet.contains(nodeId)) {
      newSet.remove(nodeId);
    } else {
      newSet.add(nodeId);
    }
    
    state = newSet;
    await _prefs!.setStringList(_key, newSet.toList());
  }
}
