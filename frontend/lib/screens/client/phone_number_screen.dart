import 'package:flutter/material.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final _phoneController = TextEditingController();
  late String _selectedNetwork;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    // Initialiser avec +225 seulement
    _phoneController.text = '+225';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args != null && args is Map<String, dynamic>) {
      _selectedNetwork = args['network'] as String? ?? 'WAVE CI';
    } else {
      _selectedNetwork = 'WAVE CI';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continueToAmount() {
    final phoneText = _phoneController.text.trim();
    if (phoneText.isNotEmpty) {
      // S'assurer que le numéro commence par +225
      String phoneNumber = phoneText;
      if (!phoneNumber.startsWith('+225')) {
        if (phoneNumber.startsWith('225')) {
          phoneNumber = '+$phoneNumber';
        } else {
          phoneNumber = '+225 $phoneNumber';
        }
      }
      
      Navigator.pushNamed(
        context,
        '/client/amount',
        arguments: {
          'network': _selectedNetwork,
          'phoneNumber': phoneNumber,
        },
      );
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
        title: const Text(
          'Numéro',
          style: TextStyle(
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
            // Instruction (dynamique selon le réseau sélectionné)
            Text(
              'Veuillez saisir votre numéro ${_selectedNetwork}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Affichage du réseau sélectionné
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        _getNetworkLogoPath(_selectedNetwork),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Nom du réseau
                  Text(
                    _selectedNetwork,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Label du numéro
            const Text(
              'numéro',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 8),
            
                         // Champ de saisie du numéro
             Container(
               decoration: BoxDecoration(
                 color: Colors.grey[100],
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(
                   color: Colors.grey[300]!,
                   width: 1,
                 ),
               ),
               child: Stack(
                 children: [
                   TextFormField(
                     controller: _phoneController,
                     keyboardType: TextInputType.phone,
                     style: const TextStyle(
                       fontSize: 18,
                       fontWeight: FontWeight.w500,
                       color: Colors.black,
                     ),
                     decoration: const InputDecoration(
                       border: InputBorder.none,
                       contentPadding: EdgeInsets.symmetric(
                         horizontal: 20,
                         vertical: 20,
                       ),
                     ),
                     onChanged: (value) {
                       // Formater automatiquement le numéro
                       if (value.startsWith('+225')) {
                         // Garder le format +225
                       } else if (value.startsWith('225')) {
                         _phoneController.text = '+$value';
                         _phoneController.selection = TextSelection.fromPosition(
                           TextPosition(offset: _phoneController.text.length),
                         );
                       }
                     },
                     onTap: () {
                       setState(() {
                         _isFocused = true;
                       });
                     },
                   ),
                                       if (!_isFocused && _phoneController.text == '+225')
                      Positioned(
                        left: 80, // Position après le +225
                        top: 20,
                        child: Text(
                          '00 00 00 00 00',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                      ),
                 ],
               ),
             ),
            
            const Spacer(),
            
            // Bouton Continuer
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _continueToAmount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626), // Rouge
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continuer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
