import 'package:flutter/material.dart';

class PulseCard extends StatefulWidget {
  final Widget child;
  final Color? pulseColor;
  final Duration pulseDuration;
  final bool enablePulse;

  const PulseCard({
    super.key,
    required this.child,
    this.pulseColor,
    this.pulseDuration = const Duration(seconds: 2),
    this.enablePulse = true,
  });

  @override
  State<PulseCard> createState() => _PulseCardState();
}

class _PulseCardState extends State<PulseCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: widget.pulseDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.enablePulse) {
      _startPulse();
    }
  }

  void _startPulse() {
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (widget.pulseColor ?? Theme.of(context).primaryColor)
                      .withOpacity(_glowAnimation.value * 0.3),
                  spreadRadius: 0,
                  blurRadius: 20 + (_glowAnimation.value * 10),
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
