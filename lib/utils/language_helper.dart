import '../constants.dart';
import '../models/language.dart';

/// Helper class for language-related operations throughout the app
class LanguageHelper {
  /// Get all available languages
  static List<Language> getAllLanguages() => kAppLanguages;
  
  /// Get current active language
  static Language? getCurrentLanguage() {
    return kAppLanguages.isEmpty 
        ? null 
        : kAppLanguages.firstWhere(
            (lang) => lang.id == kAppLanguageId,
            orElse: () => kAppLanguages.first,
          );
  }
  
  /// Get language by ID
  static Language? getLanguageById(int id) {
    try {
      return kAppLanguages.firstWhere((lang) => lang.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Get language by code (e.g., 'en', 'he')
  static Language? getLanguageByCode(String code) {
    try {
      return kAppLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }
  
  /// Check if a language is available
  static bool isLanguageAvailable(String code) {
    return kAppLanguages.any((lang) => lang.code == code);
  }
  
  /// Get all language codes
  static List<String> getAllLanguageCodes() {
    return kAppLanguages.map((lang) => lang.code).toList();
  }
  
  /// Get current language code
  static String getCurrentLanguageCode() {
    final currentLang = getCurrentLanguage();
    return currentLang?.code ?? 'en';
  }
  
  /// Check if current language is RTL (Right-to-Left)
  static bool isCurrentLanguageRTL() {
    final currentLang = getCurrentLanguage();
    return currentLang?.direction == 1; // Assuming 1 = RTL, 0 = LTR
  }
  
  /// Get default language
  static Language? getDefaultLanguage() {
    try {
      return kAppLanguages.firstWhere((lang) => lang.isDefault == 1);
    } catch (e) {
      return kAppLanguages.isNotEmpty ? kAppLanguages.first : null;
    }
  }
}