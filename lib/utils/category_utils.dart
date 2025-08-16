import '../models/category.dart';
import '../services/category_repository.dart';
import '../constants.dart';

List<Category> getCategoriesByLanguage() {
  final List<Category> filtered = CategoryRepository().categories.where((c) => c.languageId == kAppLanguageId).toList();
  return filtered;
}
