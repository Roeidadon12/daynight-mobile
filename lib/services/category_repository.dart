import '../models/category.dart';
import 'category_service.dart';

class CategoryRepository {
  static final CategoryRepository _instance = CategoryRepository._internal();
  factory CategoryRepository() => _instance;
  CategoryRepository._internal();

  List<Category> _categories = [];
  bool _loaded = false;

  List<Category> get categories => _categories;
  bool get loaded => _loaded;

  Future<void> loadCategories({int? languageId}) async {
    if (_loaded) return;
    final service = CategoryService();
    _categories = await service.getCategories(languageId: languageId);
    _loaded = true;
  }

  void clear() {
    _categories = [];
    _loaded = false;
  }
}
