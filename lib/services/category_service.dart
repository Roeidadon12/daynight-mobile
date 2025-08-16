import '../api_service.dart';
import 'dart:convert';
import '../constants.dart';
import '../models/category.dart';

class CategoryService {
  final ApiService api;

  CategoryService() : api = ApiService(baseUrl: kApiBaseUrl);

  Future<List<Category>> getCategories({int? languageId}) async {
    final response = await api.request(
      endpoint: '/active-categories',
      method: 'GET',
      queryParams: languageId != null ? {'languageId': languageId.toString()} : null,
    );
    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } catch (_) {
        return [];
      }
    } else {
      return [];
    }
  }
}
