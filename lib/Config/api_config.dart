class ApiConfig {
  // URL de producción en Railway
  static const String baseUrl = 'https://serverapi-production-8840.up.railway.app';
  
  // Para desarrollo local, puedes descomentar esta línea:
  // static const String baseUrl = 'http://localhost:3000';
  
  // Endpoints
  static const String loginEndpoint = '/login';
  static const String usersEndpoint = '/users';
  
  // Headers comunes
  static Map<String, String> get headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };
}
