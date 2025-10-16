import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/payment_service.dart';
import '../../services/barapay_service.dart';
import '../../widgets/client/barapay_button.dart';
import '../../models/barapay_payment.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  const PaymentConfirmationScreen({super.key});

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;
  bool _isCompleted = false;
  String? _error;
  Map<String, dynamic>? _paymentResult;
  bool _useBarapay = true; // Par défaut, utiliser Barapay
  bool _isBarapayConnected = false;

  late String _network;
  late String _phoneNumber;
  late double _amount;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args != null && args is Map<String, dynamic>) {
      _network = args['network'] as String? ?? 'Réseau par défaut';
      _phoneNumber = args['phoneNumber'] as String? ?? '';
      _amount = args['amount'] as double? ?? 0.0;
    } else {
      // Valeurs par défaut si pas d'arguments
      _network = 'Réseau par défaut';
      _phoneNumber = '';
      _amount = 0.0;
    }
    
    // Vérifier la connexion Barapay
    _checkBarapayConnection();
  }

  Future<void> _checkBarapayConnection() async {
    final isConnected = await BarapayService.testConnection();
    setState(() {
      _isBarapayConnected = isConnected;
    });
  }

  Future<void> _processPayment() async {
    if (_useBarapay && _isBarapayConnected) {
      await _processBarapayPayment();
    } else {
      await _processTraditionalPayment();
    }
  }

  Future<void> _processBarapayPayment() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final response = await BarapayService.createPayment(
        amount: _amount,
        phoneNumber: _phoneNumber,
        description: 'Don DONS - ${_amount.toInt()} FCFA',
        orderId: 'DONS-${DateTime.now().millisecondsSinceEpoch}',
      );

      if (response.success && response.checkoutUrl != null) {
        // Ouvrir la page de paiement Barapay
        final success = await BarapayService.openPaymentPage(response.checkoutUrl!);
        
        if (success) {
          setState(() {
            _paymentResult = {
              'transactionId': response.paymentId,
              'status': 'pending',
              'network': 'Barapay',
              'phoneNumber': _phoneNumber,
              'amount': _amount,
              'timestamp': DateTime.now().toIso8601String(),
              'barapay_reference': response.reference,
              'checkout_url': response.checkoutUrl,
            };
            _isCompleted = true;
            _isProcessing = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Page de paiement Barapay ouverte !'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('Impossible d\'ouvrir la page de paiement');
        }
      } else {
        throw Exception(response.error ?? 'Erreur lors de la création du paiement');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur Barapay: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processTraditionalPayment() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // Simuler le traitement du paiement traditionnel
      await Future.delayed(const Duration(seconds: 2));
      
      // Créer un résultat simulé
      final result = {
        'transactionId': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'success',
        'network': _network,
        'phoneNumber': _phoneNumber,
        'amount': _amount,
        'timestamp': DateTime.now().toIso8601String(),
      };

      setState(() {
        _paymentResult = result;
        _isCompleted = true;
        _isProcessing = false;
      });

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paiement traité avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          'Confirmation',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Text(
              'Confirmer votre don',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Vérifiez les informations avant de confirmer',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Carte de résumé
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Réseau de paiement
                  Row(
                    children: [
                                             Container(
                         width: 40,
                         height: 40,
                         decoration: BoxDecoration(
                           color: const Color(0xFF1E40AF), // Bleu par défaut
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: Center(
                           child: Text(
                             _network.split(' ').first,
                             style: GoogleFonts.poppins(
                               fontSize: 12,
                               fontWeight: FontWeight.bold,
                               color: Colors.white,
                             ),
                           ),
                         ),
                       ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Réseau',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                                                         Text(
                               _network,
                               style: GoogleFonts.poppins(
                                 fontSize: 16,
                                 fontWeight: FontWeight.w600,
                                 color: Colors.grey[800],
                               ),
                             ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Numéro de téléphone
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFb22222),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Numéro',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _phoneNumber,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Montant
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10b981),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.attach_money,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Montant',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${_amount.toStringAsFixed(2)} F CFA',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10b981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Sélection du mode de paiement
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mode de paiement',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Option Barapay
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _useBarapay = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _useBarapay ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _useBarapay ? const Color(0xFF4CAF50) : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.payment,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Barapay (Recommandé)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Paiement sécurisé et instantané',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (_isBarapayConnected)
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Connecté',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Row(
                                    children: [
                                      const Icon(Icons.warning, color: Colors.orange, size: 16),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Service indisponible',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.orange[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          Radio<bool>(
                            value: true,
                            groupValue: _useBarapay,
                            onChanged: (value) {
                              setState(() {
                                _useBarapay = value ?? true;
                              });
                            },
                            activeColor: const Color(0xFF4CAF50),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Option traditionnel
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _useBarapay = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: !_useBarapay ? const Color(0xFF1e3a8a).withOpacity(0.1) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !_useBarapay ? const Color(0xFF1e3a8a) : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1e3a8a),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.phone_android,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Paiement traditionnel',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'SMS de confirmation requis',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Radio<bool>(
                            value: false,
                            groupValue: _useBarapay,
                            onChanged: (value) {
                              setState(() {
                                _useBarapay = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF1e3a8a),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Message d'information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _useBarapay 
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : const Color(0xFF1e3a8a).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _useBarapay 
                      ? const Color(0xFF4CAF50).withOpacity(0.3)
                      : const Color(0xFF1e3a8a).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: _useBarapay ? const Color(0xFF4CAF50) : const Color(0xFF1e3a8a),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _useBarapay 
                          ? 'Paiement sécurisé et instantané avec Barapay. Aucun SMS requis.'
                          : 'Vous recevrez un SMS de confirmation de votre réseau mobile pour valider le paiement.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _useBarapay ? const Color(0xFF4CAF50) : const Color(0xFF1e3a8a),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Bouton de confirmation
            if (!_isCompleted) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _useBarapay ? const Color(0xFF4CAF50) : const Color(0xFFb22222),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _useBarapay ? Icons.payment : Icons.phone_android,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _useBarapay 
                                  ? 'Payer avec Barapay'
                                  : 'Confirmer le paiement',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ] else ...[
              // Résultat du paiement
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _useBarapay ? Colors.green[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _useBarapay ? Colors.green[200]! : Colors.blue[200]!,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _useBarapay ? Icons.payment : Icons.check_circle,
                      color: _useBarapay ? Colors.green[600] : Colors.blue[600],
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _useBarapay 
                          ? 'Page de paiement Barapay ouverte !'
                          : 'Paiement traité !',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _useBarapay ? Colors.green[800] : Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_useBarapay) ...[
                      Text(
                        'Référence Barapay: ${_paymentResult?['barapay_reference'] ?? 'N/A'}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Terminez le paiement dans la page ouverte',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.green[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Référence: ${_paymentResult?['transactionId'] ?? 'N/A'}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/client/campaign',
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFb22222),
                    side: const BorderSide(color: Color(0xFFb22222)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Retour à la campagne',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
