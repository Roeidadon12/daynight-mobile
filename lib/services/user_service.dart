import 'api_service.dart';

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

  Future verifyPhoneNumber(String phoneNumber, String code) {
    return api.request(
      endpoint: '/api/verify-phone',
      method: 'POST',
      body: {
        'phone_number': phoneNumber,
        'code': code,
      },
    );
  }

  Future userLogin(Map<String, dynamic> data) {
    return api.request(
      endpoint: '/api/login',
      method: 'POST',
      body: data,
    );
  }

}
