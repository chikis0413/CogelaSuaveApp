import 'environment.dart';

class ApiConfig {
  // URLs base según el entorno (ajusta si los dominios cambian por entorno).
  // Use the provided Railway-hosted Flask API for all environments by default.
  static const String _devBaseUrl = 'http://flaskapiexample-production.up.railway.app/';
  static const String _stagingBaseUrl = 'http://flaskapiexample-production.up.railway.app/';
  static const String _prodBaseUrl = 'http://flaskapiexample-production.up.railway.app/';

  // URL base del backend según el entorno
  static String get baseUrl {
    switch (EnvironmentConfig.environment) {
      case Environment.development:
        return _devBaseUrl;
      case Environment.staging:
        return _stagingBaseUrl;
      case Environment.production:
        return _prodBaseUrl;
    }
  }

  // Endpoints
  static String get loginEndpoint => '$baseUrl/auth/login.php';

  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 10);

  // Headers por defecto
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Función para verificar si la URL contiene una IP local específica
  static bool isLocalNetwork() {
    return baseUrl.contains('172.17.15.181');
  }

  // Función para obtener información de debug
  static String get debugInfo {
    return '''Entorno: ${EnvironmentConfig.environmentName}\nURL Base: $baseUrl\nEndpoint Login: $loginEndpoint\nTimeout: ${requestTimeout.inSeconds}s\nRed Local: ${isLocalNetwork()}''';
  }
}
