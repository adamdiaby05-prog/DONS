import 'package:flutter/material.dart';
import 'dart:math' as math;

class ParticleCard extends StatefulWidget {
  final Widget child;
  final Color? particleColor;
  final int particleCount;
  final Duration animationDuration;

  const ParticleCard({
    super.key,
    required this.child,
    this.particleColor,
    this.particleCount = 8,
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  State<ParticleCard> createState() => _ParticleCardState();
}

class _ParticleCardState extends State<ParticleCard>
    with TickerProviderStateMixin {
  late List<AnimationController> _particleControllers;
  late List<Animation<double>> _particleAnimations;
  late List<Animation<double>> _opacityAnimations;
  late List<Offset> _particlePositions;

  @override
  void initState() {
    super.initState();
    _initializeParticles();
  }

  void _initializeParticles() {
    _particleControllers = List.generate(
      widget.particleCount,
      (index) => AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      ),
    );

    _particleAnimations = List.generate(
      widget.particleCount,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _particleControllers[index],
        curve: Curves.easeInOut,
      )),
    );

    _opacityAnimations = List.generate(
      widget.particleCount,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _particleControllers[index],
        curve: Curves.easeInOut,
      )),
    );

    // Positions aléatoires des particules
    final random = math.Random();
    _particlePositions = List.generate(
      widget.particleCount,
      (index) => Offset(
        random.nextDouble() * 200 - 100,
        random.nextDouble() * 200 - 100,
      ),
    );

    // Démarrer les animations avec des délais échelonnés
    for (int i = 0; i < widget.particleCount; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _particleControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _particleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Contenu principal
        widget.child,
        
        // Particules flottantes
        ...List.generate(widget.particleCount, (index) {
          return AnimatedBuilder(
            animation: _particleControllers[index],
            builder: (context, child) {
              return Positioned(
                left: 100 + _particlePositions[index].dx,
                top: 100 + _particlePositions[index].dy,
                child: Transform.translate(
                  offset: Offset(
                    math.sin(_particleAnimations[index].value * 2 * math.pi) * 20,
                    math.cos(_particleAnimations[index].value * 2 * math.pi) * 20,
                  ),
                  child: Opacity(
                    opacity: _opacityAnimations[index].value * 0.6,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.particleColor ?? Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (widget.particleColor ?? Theme.of(context).primaryColor)
                                .withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
