/// 達成演出オーバーレイウィジェット
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:reading_progress_app/application/providers/celebration_provider.dart';

/// 達成演出のオーバーレイ
class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    required this.event,
    required this.onDismiss,
    super.key,
  });

  final CelebrationEvent event;
  final VoidCallback onDismiss;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // 紙吹雪パーティクルを生成
    for (int i = 0; i < 50; i++) {
      _particles.add(
        _ConfettiParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble() * -0.5,
          speed: 0.5 + _random.nextDouble() * 1.5,
          angle: _random.nextDouble() * math.pi * 2,
          color: _getRandomColor(),
          size: 8 + _random.nextDouble() * 8,
        ),
      );
    }

    _fadeController.forward();
    _scaleController.forward();
    _confettiController.forward();

    // 3秒後に自動で閉じる
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _dismiss() {
    _fadeController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _dismiss,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Stack(
              children: [
                // 背景
                Container(color: Colors.black54),
                // 紙吹雪
                if (widget.event.type == CelebrationEventType.progressMilestone)
                  AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: MediaQuery.of(context).size,
                        painter: _ConfettiPainter(
                          particles: _particles,
                          progress: _confettiController.value,
                        ),
                      );
                    },
                  ),
                // メッセージ
                Center(
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildIcon(),
                          const SizedBox(height: 16),
                          Text(
                            widget.event.message,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (widget.event.type ==
                              CelebrationEventType.progressMilestone) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${widget.event.milestone}% 達成！',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon() {
    switch (widget.event.type) {
      case CelebrationEventType.progressMilestone:
        return const Text('🎉', style: TextStyle(fontSize: 64));
      case CelebrationEventType.cheer:
        return const Text('📚', style: TextStyle(fontSize: 64));
      case CelebrationEventType.scolding:
        return const Text('💪', style: TextStyle(fontSize: 64));
    }
  }
}

class _ConfettiParticle {
  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.angle,
    required this.color,
    required this.size,
  });

  double x;
  double y;
  final double speed;
  final double angle;
  final Color color;
  final double size;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x = particle.x * size.width;
      final y = (particle.y + progress * particle.speed) * size.height;
      final rotation = particle.angle + progress * math.pi * 4;

      if (y > size.height) continue;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final paint = Paint()..color = particle.color;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
