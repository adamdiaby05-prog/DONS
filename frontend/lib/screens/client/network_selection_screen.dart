import 'package:flutter/material.dart';

class NetworkSelectionScreen extends StatefulWidget {
  const NetworkSelectionScreen({super.key});

  @override
  State<NetworkSelectionScreen> createState() => _NetworkSelectionScreenState();
}

class _NetworkSelectionScreenState extends State<NetworkSelectionScreen> {
  String? _selectedNetwork;

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
          'Réseau',
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
            // Instruction
            Text(
              'Choisissez votre réseau',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Liste des réseaux
            Expanded(
              child: ListView.separated(
                itemCount: 4,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildNetworkButton(index);
                },
              ),
            ),
            
            // Point rouge en bas (comme dans l'image)
            Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkButton(int index) {
    final networks = [
      {
        'name': 'MTN MoMo',
        'backgroundColor': Colors.white,
        'logoPath': 'assets/images/mtn.jpg',
        'textColor': Colors.black,
      },
      {
        'name': 'MOOV Money',
        'backgroundColor': Colors.white,
        'logoPath': 'assets/images/moov.jpg',
        'textColor': Colors.black,
      },
      {
        'name': 'ORANGE Money',
        'backgroundColor': Colors.white,
        'logoPath': 'assets/images/orange.jpg',
        'textColor': Colors.black,
      },
      {
        'name': 'WAVE CI',
        'backgroundColor': Colors.white,
        'logoPath': 'assets/images/Wave.jpg',
        'textColor': Colors.black,
      },
    ];

    final network = networks[index];
    final isSelected = _selectedNetwork == network['name'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNetwork = network['name'] as String;
        });
        
        // Navigation vers la page suivante après sélection
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Navigator.pushNamed(
              context,
              '/client/phone-number',
              arguments: {
                'network': network['name'],
              },
            );
          }
        });
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: network['backgroundColor'] as Color,
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
            ? Border.all(color: const Color(0xFFDC2626), width: 3)
            : Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Logo du réseau
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    network['logoPath'] as String,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Nom du réseau
              Expanded(
                child: Text(
                  network['name'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: network['textColor'] as Color,
                  ),
                ),
              ),
              
              // Indicateur de sélection
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
