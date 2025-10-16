enum Environment {
  local,      // localhost:8000
  localNetwork, // 192.168.1.7:8000 (réseau local)
  emulator,   // 10.0.2.2:8000 (émulateur Android)
  emulatorAlternative, // localhost:8000 (alternative pour émulateur)
  server,     // serveur de production
}

class EnvironmentConfig {
  static Environment currentEnvironment = Environment.local;
  
  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.local:
        return 'http://localhost:8000'; // localhost pour développement web
      case Environment.localNetwork:
        return 'http://192.168.100.7:8000'; // Utiliser l'IP correcte du réseau local
      case Environment.emulator:
        return 'http://10.0.2.2:8000';
      case Environment.emulatorAlternative:
        return 'http://localhost:8000';
      case Environment.server:
        return 'http://votre-serveur.com:8000';
    }
  }
  
  static String get environmentName {
    switch (currentEnvironment) {
      case Environment.local:
        return 'Local (localhost)';
      case Environment.localNetwork:
        return 'Réseau local (192.168.1.7:8000)';
      case Environment.emulator:
        return 'Émulateur Android';
      case Environment.emulatorAlternative:
        return 'Émulateur (localhost)';
      case Environment.server:
        return 'Serveur de production';
    }
  }
  
  // Méthode pour changer d'environnement facilement
  static void setEnvironment(Environment env) {
    currentEnvironment = env;
  }
} 