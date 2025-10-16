import 'package:flutter/material.dart';

class ChartCard extends StatefulWidget {
  final String title;
  final String value;
  final Color color;
  final Widget chartData;
  final int index; // Pour l'animation d'entrée échelonnée

  const ChartCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.chartData,
    this.index = 0,
  });

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _chartScaleAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800 + (widget.index * 150)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
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
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _chartScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    // Démarrer l'animation avec un délai échelonné
    Future.delayed(Duration(milliseconds: widget.index * 200), () {
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
                  duration: const Duration(milliseconds: 300),
                  transform: _isHovered 
                      ? (Matrix4.identity()..translate(0.0, -6.0, 0.0))
                      : Matrix4.identity(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(_isHovered ? 0.15 : 0.08),
                          spreadRadius: _isHovered ? 1 : 0,
                          blurRadius: _isHovered ? 25 : 15,
                          offset: Offset(0, _isHovered ? 10 : 6),
                        ),
                        if (_isHovered)
                          BoxShadow(
                            color: widget.color.withOpacity(0.08),
                            spreadRadius: 0,
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                      ],
                      border: Border.all(
                        color: widget.color.withOpacity(_isHovered ? 0.2 : 0.05),
                        width: _isHovered ? 1.5 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre et valeur avec animation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                    fontSize: _isHovered ? 16 : 15,
                                  ) ?? const TextStyle(),
                                  child: Text(
                                    widget.title,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: EdgeInsets.symmetric(
                                  horizontal: _isHovered ? 16 : 12,
                                  vertical: _isHovered ? 10 : 6,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.color.withOpacity(_isHovered ? 0.15 : 0.1),
                                  borderRadius: BorderRadius.circular(_isHovered ? 25 : 20),
                                  boxShadow: _isHovered ? [
                                    BoxShadow(
                                      color: widget.color.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ] : null,
                                ),
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: TextStyle(
                                    color: widget.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: _isHovered ? 18 : 16,
                                  ),
                                  child: Text(widget.value),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Graphique avec animation d'échelle
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: _isHovered ? 140 : 120,
                            child: Transform.scale(
                              scale: _chartScaleAnimation.value,
                              child: widget.chartData,
                            ),
                          ),
                          
                          // Indicateur de progression animé
                          if (_isHovered) ...[
                            const SizedBox(height: 16),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 4,
                              decoration: BoxDecoration(
                                color: widget.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: 0.7,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: widget.color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
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
        );
      },
    );
  }
}
