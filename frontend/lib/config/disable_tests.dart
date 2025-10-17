// Configuration pour désactiver tous les tests automatiques
// qui causent des requêtes GET non autorisées

class TestConfig {
  // Désactiver tous les tests de performance
  static const bool disablePerformanceTests = true;
  
  // Désactiver tous les tests de diagnostic
  static const bool disableDiagnosticTests = true;
  
  // Désactiver tous les tests de connexion
  static const bool disableConnectionTests = true;
  
  // Désactiver tous les tests d'API
  static const bool disableApiTests = true;
  
  // Mode de test sécurisé (pas de requêtes GET)
  static const bool safeMode = true;
}
