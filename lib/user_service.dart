import '../api_service.dart';

class UserService {
  final ApiService api;

  UserService(this.api);

  Future getUserProfile(String userId) {
    return api.request(
      endpoint: '/users/$userId',
      method: 'GET',
    );
  }

  Future updateUserProfile(String userId, Map<String, dynamic> data) {
    return api.request(
      endpoint: '/users/$userId',
      method: 'PUT',
      body: data,
    );
  }
}
