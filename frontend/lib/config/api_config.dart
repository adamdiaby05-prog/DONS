import 'environment.dart';

class ApiConfig {
  // Configuration pour l'environnement de développement
  static const bool isDevelopment = true;
  
  // URLs de base selon l'environnement
  static const String localBaseUrl = 'http://localhost:8000'; // Pour le développement local
  static const String emulatorBaseUrl = 'http://10.0.2.2:8000'; // Pour l'émulateur Android
  static const String serverBaseUrl = 'http://votre-serveur.com:8000'; // URL de votre serveur
  
  // URL active selon l'environnement
  static String get baseUrl {
    return EnvironmentConfig.baseUrl;
  }
  
  // Timeouts de connexion optimisés
  static const int connectTimeout = 3; // secondes
  static const int receiveTimeout = 5; // secondes
  
  // Headers par défaut
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Endpoints de l'API
  static const String paymentsInitiate = '/api/payments/initiate';
  static const String paymentsStatus = '/api/payments';
  static const String testEndpoint = '/api/test';
} 