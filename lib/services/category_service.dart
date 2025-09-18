import '../api_service.dart';
import '../constants.dart';
import '../models/category.dart';
import '../models/enums.dart';

class CategoryService {
  final ApiService api;

  CategoryService() : api = ApiService(baseUrl: kApiBaseUrl);

  Future<List<Category>> getCategories({int? languageId}) async {
    final response = await api.request(
      endpoint: ApiCommands.getCategories.value,
      method: 'GET',
      queryParams: languageId != null ? {'language_id': languageId.toString()} : null,
    );
    try {
      if (!response.containsKey('categories')) {
        return [];
      }
      final categoriesList = response['categories'];

      return (categoriesList as List)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error parsing categories: $e');
      return [];
    }
  }
}
