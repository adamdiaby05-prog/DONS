import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/barapay_service.dart';
import '../../models/barapay_payment.dart';
import '../custom_button.dart';

class BarapayButton extends StatefulWidget {
  final double amount;
  final String phoneNumber;
  final String? description;
  final String? orderId;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentError;
  final String? buttonText;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const BarapayButton({
    Key? key,
    required this.amount,
    required this.phoneNumber,
    this.description,
    this.orderId,
    this.onPaymentSuccess,
    this.onPaymentError,
    this.buttonText,
    this.backgroundColor,
    this.textColor,
    this.icon,
  }) : super(key: key);

  @override
  State<BarapayButton> createState() => _BarapayButtonState();
}

class _BarapayButtonState extends State<BarapayButton>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    _animationController.forward();

    try {
      // Créer le paiement
      final response = await BarapayService.createPayment(
        amount: widget.amount,
        phoneNumber: widget.phoneNumber,
        description: widget.description,
        orderId: widget.orderId,
      );

      if (response.success && response.checkoutUrl != null) {
        // Ouvrir la page de paiement
        final success = await BarapayService.openPaymentPage(response.checkoutUrl!);
        
        if (success) {
          widget.onPaymentSuccess?.call();
        } else {
          _showError('Impossible d\'ouvrir la page de paiement');
        }
      } else {
        _showError(response.error ?? 'Erreur lors de la création du paiement');
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      _animationController.reverse();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    widget.onPaymentError?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: CustomButton(
        text: widget.buttonText ?? 'Payer avec Barapay',
        onPressed: _isLoading ? null : _handlePayment,
        isLoading: _isLoading,
        backgroundColor: widget.backgroundColor ?? const Color(0xFF4CAF50),
        textColor: widget.textColor ?? Colors.white,
        icon: widget.icon ?? Icons.payment,
      ),
    );
  }
}

/// Widget compact pour les paiements rapides
class BarapayQuickButton extends StatelessWidget {
  final double amount;
  final String phoneNumber;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentError;

  const BarapayQuickButton({
    Key? key,
    required this.amount,
    required this.phoneNumber,
    this.onPaymentSuccess,
    this.onPaymentError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarapayButton(
      amount: amount,
      phoneNumber: phoneNumber,
      onPaymentSuccess: onPaymentSuccess,
      onPaymentError: onPaymentError,
      buttonText: 'Payer ${amount.toInt()} FCFA',
      backgroundColor: const Color(0xFF4CAF50),
      icon: Icons.payment,
    );
  }
}

/// Widget pour les paiements avec montant personnalisé
class BarapayCustomButton extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentError;

  const BarapayCustomButton({
    Key? key,
    required this.phoneNumber,
    this.onPaymentSuccess,
    this.onPaymentError,
  }) : super(key: key);

  @override
  State<BarapayCustomButton> createState() => _BarapayCustomButtonState();
}

class _BarapayCustomButtonState extends State<BarapayCustomButton> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Paiement Barapay',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant (FCFA)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.money),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optionnel)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _processPayment(amount, _descriptionController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer un montant valide'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: Text('Payer'),
          ),
        ],
      ),
    );
  }

  void _processPayment(double amount, String description) {
    // Utiliser le BarapayButton pour traiter le paiement
    // Ceci est un exemple - dans un vrai projet, vous pourriez
    // naviguer vers un écran de paiement dédié
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarapayButton(
          amount: amount,
          phoneNumber: widget.phoneNumber,
          description: description.isNotEmpty ? description : null,
          onPaymentSuccess: widget.onPaymentSuccess,
          onPaymentError: widget.onPaymentError,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BarapayButton(
      amount: 0, // Sera remplacé par le montant saisi
      phoneNumber: widget.phoneNumber,
      onPaymentSuccess: widget.onPaymentSuccess,
      onPaymentError: widget.onPaymentError,
      buttonText: 'Paiement personnalisé',
      backgroundColor: const Color(0xFF2196F3),
      icon: Icons.add,
    );
  }
}
