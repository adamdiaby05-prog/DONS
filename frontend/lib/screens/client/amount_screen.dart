import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/payment_service.dart';
import '../../models/payment_network.dart';
import '../../services/api_test_service.dart';
import '../../services/connection_diagnostic_service.dart';
import '../../config/environment.dart';

class AmountScreen extends StatefulWidget {
  const AmountScreen({super.key});

  @override
  State<AmountScreen> createState() => _AmountScreenState();
}

class _AmountScreenState extends State<AmountScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late String _network;
  late String _phoneNumber;

  @override
  void initState() {
    super.initState();
    // Initialiser avec 0 FCFA
    _amountController.text = '0 FCFA';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args != null && args is Map<String, dynamic>) {
      _network = args['network'] as String? ?? 'Réseau par défaut';
      _phoneNumber = args['phoneNumber'] as String? ?? '';
    } else {
      // Valeurs par défaut si pas d'arguments
      _network = 'Réseau par défaut';
      _phoneNumber = '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

    Future<void> _validatePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Nettoyer et convertir le montant en int (votre méthode)
      String saisie = _amountController.text.replaceAll("FCFA", "").trim();
      
      // Vérifier que la saisie est valide
      if (saisie.isEmpty) {
        throw Exception('Veuillez saisir un montant valide');
      }
      
      // Convertir en int avec gestion d'erreur
      int amount;
      try {
        amount = int.parse(saisie);
      } catch (e) {
        throw Exception('Montant invalide: $saisie. Veuillez saisir un nombre entier.');
      }
      
      if (amount <= 0) {
        throw Exception('Le montant doit être supérieur à 0');
      }

              // Tester la connexion à l'API avant d'effectuer le paiement
        final apiTestService = ApiTestService();
        final isConnected = await apiTestService.testConnection();
        
        if (!isConnected) {
          // Effectuer un diagnostic détaillé
          final diagnosticService = ConnectionDiagnosticService();
          final diagnosis = await diagnosticService.diagnoseConnection();
          final suggestions = diagnosticService.getResolutionSuggestions(diagnosis);
          
          throw Exception('Impossible de se connecter au serveur.\n\nDiagnostic:\n${suggestions.join('\n')}');
        }

      // Créer une instance du service de paiement
      final paymentService = PaymentService();
      
      // Créer un objet PaymentNetwork pour le réseau sélectionné
      final paymentNetwork = PaymentNetwork(
        id: _getNetworkId(_network),
        name: _network,
        logo: _getNetworkLogoPath(_network),
        backgroundColor: _getNetworkColor(_network),
        description: 'Réseau de paiement mobile',
      );

      // Appeler l'API pour initier le paiement
      final paymentResult = await paymentService.initiatePayment(
        network: paymentNetwork,
        phoneNumber: _phoneNumber,
        amount: amount,
      );

      if (mounted) {
        // Vérifier si c'est un paiement Barapay avec redirection
        if (paymentResult['redirect_required'] == true && paymentResult['checkout_url'] != null) {
          // C'est un paiement Barapay RÉEL - rediriger vers l'URL de checkout
          final checkoutUrl = paymentResult['checkout_url'];
          final reference = paymentResult['reference'] ?? paymentResult['id'] ?? 'N/A';
          
          // Afficher une boîte de dialogue pour confirmer la redirection
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(
                'Paiement Barapay RÉEL',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Un paiement RÉEL va être effectué via Barapay.',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Référence: $reference',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vous allez être redirigé vers la page de paiement Barapay.',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Ouvrir l'URL de paiement Barapay
                    _openBarapayCheckout(checkoutUrl);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFb22222),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Continuer vers Barapay'),
                ),
              ],
            ),
          );
        } else {
          // Vérifier si c'est un paiement Barapay mais sans redirection explicite
          if (paymentResult['real_payment'] == true || paymentResult['barapay_payment'] == true) {
            // C'est un paiement Barapay mais sans URL de checkout
            final reference = paymentResult['reference'] ?? paymentResult['id'] ?? 'N/A';
            
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: Text(
                  'Paiement Barapay RÉEL',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Un paiement RÉEL a été initié via Barapay.',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Référence: $reference',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '⚠️ ATTENTION: Ce paiement débitera RÉELLEMENT votre compte mobile money !',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(
                        context,
                        '/client/candidate-presentation',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFb22222),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Continuer'),
                  ),
                ],
              ),
            );
          } else {
            // Paiement normal (simulé)
            final reference = paymentResult['reference'] ?? paymentResult['id'] ?? 'N/A';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Paiement initié avec succès! Référence: $reference'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );

            // Attendre un peu puis naviguer vers la présentation du candidat
            await Future.delayed(const Duration(seconds: 2));
            
            if (mounted) {
              Navigator.pushNamed(
                context,
                '/client/candidate-presentation',
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        // Afficher un message d'erreur plus informatif
        String errorMessage = 'Erreur lors du paiement';
        
        if (e.toString().contains('Connection refused') || e.toString().contains('Impossible de se connecter')) {
          errorMessage = e.toString();
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Délai d\'attente dépassé. Vérifiez votre connexion internet.';
        } else {
          errorMessage = 'Erreur: $e';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: () {
                _validatePayment();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateAmount(String value) {
    if (value.isEmpty) {
      _amountController.text = '0 FCFA';
      return;
    }

    // Supprimer les caractères non numériques
    final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numericValue.isEmpty) {
      _amountController.text = '0 FCFA';
      return;
    }

    try {
      final amount = int.parse(numericValue);
      _amountController.text = '$amount FCFA';
    } catch (e) {
      _amountController.text = '0 FCFA';
    }
  }

  String _getNetworkLogoPath(String networkName) {
    switch (networkName) {
      case 'MTN MoMo':
        return 'assets/images/mtn.jpg';
      case 'MOOV Money':
        return 'assets/images/moov.jpg';
      case 'ORANGE Money':
        return 'assets/images/orange.jpg';
      case 'WAVE CI':
        return 'assets/images/Wave.jpg';
      default:
        return 'assets/images/Wave.jpg';
    }
  }

  String _getNetworkId(String networkName) {
    switch (networkName) {
      case 'MTN MoMo':
        return 'mtn_momo';
      case 'MOOV Money':
        return 'moov_money';
      case 'ORANGE Money':
        return 'orange_money';
      case 'WAVE CI':
        return 'wace_ci';
      default:
        return 'wace_ci';
    }
  }

  Color _getNetworkColor(String networkName) {
    switch (networkName) {
      case 'MTN MoMo':
        return const Color(0xFFFFD700); // Jaune
      case 'MOOV Money':
        return const Color(0xFF87CEEB); // Bleu clair
      case 'ORANGE Money':
        return const Color(0xFFFFA500); // Orange
      case 'WAVE CI':
        return const Color(0xFF87CEEB); // Bleu clair
      default:
        return const Color(0xFF87CEEB);
    }
  }

  // Méthode pour ouvrir l'URL de paiement Barapay
  void _openBarapayCheckout(String checkoutUrl) {
    // Pour Flutter Web, utiliser window.open
    // En production, vous devriez utiliser le package url_launcher
    try {
      // Ouvrir dans un nouvel onglet
      // Note: En Flutter Web, cela fonctionne avec dart:html
      if (checkoutUrl.isNotEmpty) {
        // Afficher l'URL dans une boîte de dialogue pour que l'utilisateur puisse la copier
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Redirection vers Barapay',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cliquez sur le lien ci-dessous pour effectuer le paiement Barapay RÉEL:',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SelectableText(
                    checkoutUrl,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '⚠️ ATTENTION: Ce paiement débitera RÉELLEMENT votre compte mobile money !',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // En Flutter Web, on peut essayer d'ouvrir l'URL
                  // Mais pour l'instant, on affiche juste l'URL
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('URL Barapay: $checkoutUrl'),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFb22222),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ouvrir Barapay'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ouverture de Barapay: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Méthode pour diagnostiquer la connexion
  Future<void> _runDiagnostic() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final diagnosticService = ConnectionDiagnosticService();
      final diagnosis = await diagnosticService.diagnoseConnection();
      final suggestions = diagnosticService.getResolutionSuggestions(diagnosis);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Diagnostic de connexion',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Environnement: ${diagnosis['environment']}'),
                Text('URL: ${diagnosis['base_url']}'),
                const SizedBox(height: 16),
                Text(
                  'Résultats des tests:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildDiagnosticResult('API principale', diagnosis['main_api']),
                const SizedBox(height: 8),
                _buildDiagnosticResult('API Paiements', diagnosis['payments_api']),
                const SizedBox(height: 16),
                Text(
                  'Suggestions:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...suggestions.map((suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $suggestion'),
                )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du diagnostic: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildDiagnosticResult(String name, Map<String, dynamic> result) {
    final isSuccess = result['status'] == 'success';
    return Row(
      children: [
        Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          color: isSuccess ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$name: ${isSuccess ? 'OK' : 'Erreur'}',
            style: TextStyle(
              color: isSuccess ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Montant',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instruction
              Text(
                'Veuillez entrer le montant souhaité',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              
                            const SizedBox(height: 20),
              
              // Affichage du réseau et du numéro
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: const Color(0xFFE3F2FD), // Bleu clair comme sur la photo
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(
                     color: Colors.grey[300]!,
                     width: 1,
                   ),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.1),
                       blurRadius: 8,
                       offset: const Offset(0, 4),
                     ),
                   ],
                 ),
                 child: Row(
                   children: [
                     // Logo du réseau
                     Container(
                       width: 40,
                       height: 40,
                       decoration: BoxDecoration(
                         color: const Color(0xFF1976D2), // Fond bleu foncé pour le logo
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: ClipRRect(
                         borderRadius: BorderRadius.circular(8),
                         child: Image.asset(
                           _getNetworkLogoPath(_network),
                           fit: BoxFit.cover,
                         ),
                       ),
                     ),
                     
                     const SizedBox(width: 12),
                     
                     // Numéro de téléphone
                     Text(
                       _phoneNumber,
                       style: GoogleFonts.poppins(
                         fontSize: 16,
                         fontWeight: FontWeight.w500,
                         color: Colors.black,
                       ),
                     ),
                   ],
                 ),
               ),
              
              const SizedBox(height: 20),
              
              // Label du montant
              Text(
                'Montant',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              
              const SizedBox(height: 8),
              
                             // Champ de saisie du montant
               Container(
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(
                     color: Colors.grey[300]!,
                     width: 1.5,
                   ),
                 ),
                 child: TextFormField(
                   controller: _amountController,
                   keyboardType: TextInputType.number,
                   style: GoogleFonts.poppins(
                     fontSize: 24,
                     fontWeight: FontWeight.bold,
                     color: Colors.black,
                   ),
                   textAlign: TextAlign.center,
                   decoration: InputDecoration(
                    hintText: '0 FCFA',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    suffixText: 'FCFA',
                    suffixStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                                       onChanged: (value) {
                      // Permettre la saisie directe des chiffres
                      if (value.isNotEmpty) {
                        // Supprimer tout sauf les chiffres (votre méthode)
                        final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (cleanValue.isNotEmpty) {
                          try {
                            final amount = int.parse(cleanValue);
                            if (amount > 0) {
                              _amountController.text = '$amount FCFA';
                              // Positionner le curseur avant "FCFA"
                              _amountController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _amountController.text.length - 5),
                              );
                            }
                          } catch (e) {
                            // En cas d'erreur, remettre la valeur précédente
                            print('Erreur de parsing: $e');
                          }
                        }
                      }
                    },
                                       validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir un montant';
                      }
                      
                      // Utiliser la même logique de nettoyage que dans _validatePayment
                      String saisie = value.replaceAll("FCFA", "").trim();
                      
                      if (saisie.isEmpty) {
                        return 'Veuillez saisir un montant valide';
                      }
                      
                      final amount = int.tryParse(saisie);
                      if (amount == null || amount <= 0) {
                        return 'Montant invalide. Veuillez saisir un nombre entier positif.';
                      }
                      
                      return null;
                    },
                 ),
               ),
              
              const SizedBox(height: 20),
              
              // Bouton de validation
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _validatePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFb22222),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Traitement...',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Valider',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              // Padding en bas pour éviter le débordement
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
