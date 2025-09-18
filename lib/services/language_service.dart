import '../api_service.dart';
import '../constants.dart';
import '../models/language.dart';
import '../models/enums.dart';
import 'dart:io';
import '../utils/logger.dart';

class LanguageService {
  final ApiService api;
  
  LanguageService() : api = ApiService(
    baseUrl: kApiBaseUrl,
    timeout: const Duration(seconds: 60)  // Custom timeout for language service
  );

  Future<List<Language>> getLanguages() async {
    const int maxRetries = 3;
    int currentTry = 0;
    
    while (currentTry < maxRetries) {
      try {
        // Log attempt number if retrying
        if (currentTry > 0) {
          Logger.info('Retrying language fetch attempt ${currentTry + 1}/$maxRetries', 'LanguageService');
        }
        
        final response = await api.request(
          endpoint: ApiCommands.getLanguages.value,
          method: 'GET',
        );

        if (!response.containsKey('languages')) {
          Logger.error('Response missing languages key', 'LanguageService');
          throw Exception('Response missing languages key');
        }
        
        final languagesList = response['languages'] as List;
        final languages = languagesList
            .map((json) => Language.fromJson(json as Map<String, dynamic>))
            .toList();
        
        if (languages.isEmpty) {
          Logger.warning('No languages returned from API', 'LanguageService');
        } else {
          Logger.info('Successfully fetched ${languages.length} languages', 'LanguageService');
        }
        
        return languages;
      } on SocketException catch (e) {
        Logger.error('Network error: ${e.message}', 'LanguageService');
        if (currentTry == maxRetries - 1) throw Exception('Failed to connect to server: ${e.message}');
      } catch (e, stackTrace) {
        Logger.error(
          'Error fetching languages: $e\nStack trace: $stackTrace',
          'LanguageService'
        );
        
        if (currentTry == maxRetries - 1) {
          throw Exception('Failed to fetch languages after $maxRetries attempts');
        }
      }
      
      // Wait before retrying
      await Future.delayed(Duration(seconds: 1 << currentTry)); // Exponential backoff
      currentTry++;
    }
    
    // This should never be reached due to the throw in the last retry
    return [];
  }
}
