import 'package:flutter/material.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final int index; // Pour l'animation d'entrée échelonnée

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.index = 0,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _iconRotationAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Démarrer l'animation avec un délai échelonné
    Future.delayed(Duration(milliseconds: widget.index * 150), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: _isHovered 
                      ? (Matrix4.identity()..translate(0.0, -8.0, 0.0))
                      : Matrix4.identity(),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(_isHovered ? 0.2 : 0.1),
                            spreadRadius: _isHovered ? 2 : 1,
                            blurRadius: _isHovered ? 20 : 10,
                            offset: Offset(0, _isHovered ? 8 : 4),
                          ),
                          if (_isHovered)
                            BoxShadow(
                              color: widget.color.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                        ],
                        border: Border.all(
                          color: widget.color.withOpacity(_isHovered ? 0.3 : 0.1),
                          width: _isHovered ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Icône et titre avec animation de rotation
                            Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: EdgeInsets.all(_isHovered ? 16 : 12),
                                  decoration: BoxDecoration(
                                    color: widget.color.withOpacity(_isHovered ? 0.2 : 0.1),
                                    borderRadius: BorderRadius.circular(_isHovered ? 16 : 12),
                                    boxShadow: _isHovered ? [
                                      BoxShadow(
                                        color: widget.color.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ] : null,
                                  ),
                                  child: Transform.rotate(
                                    angle: _iconRotationAnimation.value * 0.1,
                                    child: Icon(
                                      widget.icon,
                                      color: widget.color,
                                      size: _isHovered ? 28 : 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Valeur avec animation de compteur
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 500),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.bold,
                                fontSize: _isHovered ? 28 : 24,
                              ) ?? const TextStyle(),
                              child: Text(widget.value),
                            ),
                            
                            // Indicateur de progression avec animation
                            if (widget.onTap != null) ...[
                              const SizedBox(height: 12),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                                  transform: _isHovered 
                      ? (Matrix4.identity()..translate(8.0, 0.0, 0.0))
                      : Matrix4.identity(),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: widget.color,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Voir détails',
                                      style: TextStyle(
                                        color: widget.color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
