// File: lib/services/favorites_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'favorites';

  // Get all favorite POI IDs
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  // Add POI to favorites
  static Future<bool> addFavorite(String poiId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    if (!favorites.contains(poiId)) {
      favorites.add(poiId);
      return await prefs.setStringList(_key, favorites);
    }
    return false;
  }

  // Remove POI from favorites
  static Future<bool> removeFavorite(String poiId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    if (favorites.contains(poiId)) {
      favorites.remove(poiId);
      return await prefs.setStringList(_key, favorites);
    }
    return false;
  }

  // Check if POI is favorite
  static Future<bool> isFavorite(String poiId) async {
    final favorites = await getFavorites();
    return favorites.contains(poiId);
  }

  // Toggle favorite (add if not exists, remove if exists)
  static Future<bool> toggleFavorite(String poiId) async {
    final isFav = await isFavorite(poiId);

    if (isFav) {
      await removeFavorite(poiId);
      return false; // Now not favorite
    } else {
      await addFavorite(poiId);
      return true; // Now favorite
    }
  }

  // Clear all favorites
  static Future<bool> clearAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_key);
  }
}
