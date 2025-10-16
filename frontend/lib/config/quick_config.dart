// Configuration rapide pour changer d'environnement
// Modifiez cette valeur pour basculer entre les environnements

import 'environment.dart';

// Changez cette valeur selon votre environnement :
// - Environment.local : pour le développement local (localhost:8000)
// - Environment.emulator : pour l'émulateur Android (10.0.2.2:8000)
// - Environment.server : pour le serveur de production

void configureEnvironment() {
  // Décommentez la ligne correspondante à votre environnement :
  
  // Pour le développement local (votre ordinateur)
  // EnvironmentConfig.setEnvironment(Environment.local);
  
  // Pour l'émulateur Android
  // EnvironmentConfig.setEnvironment(Environment.emulator);
  
  // Pour le réseau local (appareil mobile physique)
  EnvironmentConfig.setEnvironment(Environment.localNetwork);
  
  // Pour le serveur de production
  // EnvironmentConfig.setEnvironment(Environment.server);
} 