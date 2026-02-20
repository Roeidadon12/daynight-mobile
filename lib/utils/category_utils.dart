import '../models/category.dart';
import '../services/category_repository.dart';
import '../constants.dart';

/// Get categories for the current app language
List<Category> getCategoriesByLanguage() {
  return CategoryRepository().getCategoriesByLanguage(kAppLanguageId);
}

/// Get categories for a specific language ID
List<Category> getCategoriesByLanguageId(int languageId) {
  return CategoryRepository().getCategoriesByLanguage(languageId);
}
