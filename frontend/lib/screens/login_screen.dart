import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  
  late AnimationController _logoAnimationController;
  late AnimationController _formAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _formSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _formAnimationController.forward();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _formAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simuler un délai de connexion
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Implémenter la logique de connexion réelle
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/client/main');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
                              // Header avec logo AD et icône de confidentialité
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo AD à gauche
                    Image.asset(
                      'assets/images/ad.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    
                    // Image shield à droite
                    Container(
                      width: 25,
                      height: 25,
                      child: Image.asset(
                        'assets/images/shield.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contenu principal avec scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        
                        // Slogan principal
                        AnimatedBuilder(
                          animation: _logoAnimationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _logoScaleAnimation.value,
                              child: Text(
                                'EN MARCHE POUR UNE CÔTE\nD\'IVOIRE SOUVERAINE, JUSTE,\nET FORTE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  height: 1.2,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Mots-clés
                        Text(
                          'SOUVERAINETÉ - ÉGALITÉ - JUSTICE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.black.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Image pa.png
                        AnimatedBuilder(
                          animation: _formAnimationController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _formSlideAnimation.value),
                              child: Opacity(
                                opacity: _formFadeAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 30,
                                        offset: const Offset(0, 20),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      'assets/images/pa.png',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Vision 2030
                        AnimatedBuilder(
                          animation: _formAnimationController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _formSlideAnimation.value * 0.5),
                              child: Opacity(
                                opacity: _formFadeAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFCE7F3), // Rose clair
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFDC2626),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Notre vision pour 2030',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFDC2626),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Une Côte d\'Ivoire prospère où chaque citoyen a accès à l\'éducation, aux soins de santé et aux opportunités d\'emploi. Ensemble, nous bâtirons un pays uni dans sa diversité, fort de ses valeurs et tourné vers l\'avenir.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[800],
                                          height: 1.4,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // Bouton Faire un don (déplacé hors de la section Vision 2030)
                        AnimatedBuilder(
                          animation: _formAnimationController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _formSlideAnimation.value * 0.5),
                              child: Opacity(
                                opacity: _formFadeAnimation.value,
                                child: Container(
                                  width: double.infinity,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFDC2626).withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        // Navigation vers la page de sélection de réseau
                                        Navigator.pushNamed(context, '/client/donation');
                                      },
                                      child: Center(
                                        child: Text(
                                          'Faire un don',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

