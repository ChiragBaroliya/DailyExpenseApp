import '../../core/network/api_client.dart';
import '../models/register_request.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthService {
  final ApiClient _api;

  AuthService({ApiClient? api}) : _api = api ?? ApiClient();

  /// Calls POST /auth/login and returns a [LoginResponse].
  Future<LoginResponse> login(LoginRequest req) async {
    final res = await _api.post('/auth/login', body: req.toJson());
    if (res is Map<String, dynamic>) {
      return LoginResponse.fromJson(res);
    }
    throw ApiException('Unexpected login response');
  }

  /// Register a new user. Endpoint returns 200 OK with empty body on success.
  Future<void> register(RegisterRequest req) async {
    try {
      await _api.post('/auth/register', body: req.toJson());
      return;
    } on ApiException {
      rethrow;
    }
  }
}
