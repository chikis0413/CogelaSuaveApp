// Configuration simple para seleccionar el entorno de la aplicación.
// Modifica `EnvironmentConfig.environment` en tiempo de desarrollo o tests
// para apuntar a staging/production según sea necesario.

enum Environment { development, staging, production }

class EnvironmentConfig {
  // Valor por defecto; cambiar a `Environment.staging` o
  // `Environment.production` según sea necesario antes de compilar.
  static Environment environment = Environment.development;

  static String get environmentName {
    switch (environment) {
      case Environment.development:
        return 'development';
      case Environment.staging:
        return 'staging';
      case Environment.production:
        return 'production';
    }
  }

  // Helper para cambiar el entorno en tiempo de ejecución (útil en tests)
  static void setEnvironment(Environment env) => environment = env;
}
