class ApiConstants {
  // Base API URL (root). Use the API root rather than the Swagger UI URL.
  static const String baseUrl = 'https://dailyexpensemanager.onrender.com';

  // Default headers used for JSON requests
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };
}
