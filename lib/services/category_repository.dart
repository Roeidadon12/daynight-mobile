import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../constants.dart';
import 'category_service.dart';

class CategoryRepository {
  static final CategoryRepository _instance = CategoryRepository._internal();
  factory CategoryRepository() => _instance;
  CategoryRepository._internal();

  // Store categories grouped by language ID
  Map<int, List<Category>> _categoriesByLanguage = {};
  bool _loaded = false;

  static const String _categoriesKey = 'app_categories';

  List<Category> get categories => _categoriesByLanguage[kAppLanguageId] ?? [];
  bool get loaded => _loaded;

  /// Get categories for a specific language
  List<Category> getCategoriesByLanguage(int languageId) {
    return _categoriesByLanguage[languageId] ?? [];
  }

  /// Get all categories across all languages
  Map<int, List<Category>> get allCategories => Map.unmodifiable(_categoriesByLanguage);

  /// Load categories for all available languages from API and save to preferences
  Future<void> loadAllCategories() async {
    try {
      // Try to load from preferences first
      await _loadFromPreferences();
      
      if (_loaded && _categoriesByLanguage.isNotEmpty) {
        return; // Already loaded from preferences
      }

      // If not in preferences or empty, fetch from API
      final service = CategoryService();
      _categoriesByLanguage.clear();

      // Load categories for each language
      for (final language in kAppLanguages) {
        final categories = await service.getCategories(languageId: language.id);
        if (categories.isNotEmpty) {
          _categoriesByLanguage[language.id] = categories;
        }
      }

      _loaded = true;
      await _saveToPreferences();
    } catch (e) {
      print('Error loading all categories: $e');
      _loaded = false;
    }
  }

  /// Load categories for a specific language (legacy support)
  Future<void> loadCategories({int? languageId}) async {
    if (_loaded) return;
    
    // If loading for a specific language, just load all
    await loadAllCategories();
  }

  /// Save categories to SharedPreferences
  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> categoriesMap = {};
      
      _categoriesByLanguage.forEach((languageId, categories) {
        categoriesMap[languageId.toString()] = 
          categories.map((cat) => cat.toJson()).toList();
      });
      
      final jsonString = jsonEncode(categoriesMap);
      await prefs.setString(_categoriesKey, jsonString);
    } catch (e) {
      print('Error saving categories to preferences: $e');
    }
  }

  /// Load categories from SharedPreferences
  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_categoriesKey);
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> categoriesMap = jsonDecode(jsonString);
        _categoriesByLanguage.clear();
        
        categoriesMap.forEach((key, value) {
          final languageId = int.parse(key);
          final categoryList = (value as List)
              .map((json) => Category.fromJson(json as Map<String, dynamic>))
              .toList();
          _categoriesByLanguage[languageId] = categoryList;
        });
        
        _loaded = _categoriesByLanguage.isNotEmpty;
      }
    } catch (e) {
      print('Error loading categories from preferences: $e');
      _categoriesByLanguage.clear();
      _loaded = false;
    }
  }

  /// Force refresh categories from API
  Future<void> refreshCategories() async {
    _loaded = false;
    _categoriesByLanguage.clear();
    await loadAllCategories();
  }

  void clear() {
    _categoriesByLanguage.clear();
    _loaded = false;
  }
}
