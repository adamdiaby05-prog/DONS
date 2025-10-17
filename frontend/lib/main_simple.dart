import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DONS - Système de Don',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DONS - Système de Don'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎯 DONS - Système de Don',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Système de gestion de cotisations pour groupes et associations',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✅ Services opérationnels',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          SizedBox(height: 5),
                          Text('• Backend Laravel : http://localhost:8000'),
                          Text('• API Dons : http://localhost:8000/api/dons'),
                          Text('• API Paiements : http://localhost:8000/api/payments'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Fonctionnalités disponibles :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _buildFeatureCard('👥 Gestion des groupes', 'Créez et gérez vos groupes d\'associations'),
            _buildFeatureCard('💰 Suivi des cotisations', 'Suivez les paiements et contributions en temps réel'),
            _buildFeatureCard('🔒 Paiements sécurisés', 'Intégration avec BPay pour des paiements sécurisés'),
            _buildFeatureCard('📊 Tableau de bord', 'Interface complète de gestion pour les administrateurs'),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Test de connexion API
                  _testApiConnection();
                },
                child: Text('Tester la connexion API'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(Icons.check_circle, color: Colors.green),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }

  void _testApiConnection() {
    // Simulation d'un test de connexion
    print('Test de connexion API...');
    // Ici vous pourriez ajouter une vraie requête HTTP
  }
}
