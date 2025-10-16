import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'campaign_screen.dart';
import 'network_selection_screen.dart';
import 'phone_number_screen.dart';
import 'amount_screen.dart';
import 'payment_confirmation_screen.dart';

class ClientMainScreen extends StatefulWidget {
  const ClientMainScreen({super.key});

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CampaignScreen(),
    const NetworkSelectionScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.campaign),
      label: 'Campagne',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.payment),
      label: 'Paiement',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _bottomNavItems,
        selectedItemColor: const Color(0xFFb22222),
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
