import '../api_service.dart';
import 'dart:convert';
import '../constants.dart';
import '../models/language.dart';

class LanguageService {
  final ApiService api;

  LanguageService() : api = ApiService(baseUrl: kApiBaseUrl);

  Future<List<Language>> getLanguages() async {
    final response = await api.request(
      endpoint: '/languages',
      method: 'GET',
    );
    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Language.fromJson(json)).toList();
      } catch (_) {
        return [];
      }
    } else {
      return [];
    }
  }
}
