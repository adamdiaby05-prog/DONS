import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/quick_config.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/groups_management_screen.dart';
import 'screens/admin/members_management_screen.dart';
import 'screens/admin/contributions_management_screen.dart';
import 'screens/admin/reports_screen.dart';
import 'screens/admin/settings_screen.dart';
import 'screens/admin_demo_screen.dart';
import 'screens/client/client_main_screen.dart';
import 'screens/client/campaign_screen.dart';
import 'screens/client/network_selection_screen.dart';
import 'screens/client/phone_number_screen.dart';
import 'screens/client/amount_screen.dart';
import 'screens/client/payment_confirmation_screen.dart';
import 'screens/client/candidate_presentation_screen.dart';

void main() {
  // Configurer l'environnement avant de lancer l'app
  configureEnvironment();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion de Cotisations',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF1E3A8A),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(
            color: Color(0xFF1E3A8A),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: const Color(0xFF667eea),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.red[400]!,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.red[400]!,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin/demo': (context) => const AdminDemoScreen(),
        '/admin/dashboard': (context) => const AdminDashboardScreen(),
        '/admin/groups': (context) => const GroupsManagementScreen(),
        '/admin/members': (context) => const MembersManagementScreen(),
        '/admin/contributions': (context) => const ContributionsManagementScreen(),
        '/admin/reports': (context) => const ReportsScreen(),
        '/admin/settings': (context) => const SettingsScreen(),
        // Routes client
        '/client': (context) => const ClientMainScreen(),
        '/client/campaign': (context) => const CampaignScreen(),
        '/client/donation': (context) => const NetworkSelectionScreen(),
        '/client/phone-number': (context) => const PhoneNumberScreen(),
        '/client/amount': (context) => const AmountScreen(),
        '/client/payment-confirmation': (context) => const PaymentConfirmationScreen(),
        '/client/candidate-presentation': (context) => const CandidatePresentationScreen(),
        // Ajouter d'autres routes ici
      },
    );
  }
}
