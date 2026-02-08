import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'progress_state.dart';

/// Joyful completion screen with colorful confetti papers scattering from the top.
class VocabularyCompleteScreen extends StatefulWidget {
  const VocabularyCompleteScreen({super.key});

  @override
  State<VocabularyCompleteScreen> createState() => _VocabularyCompleteScreenState();
}

class _VocabularyCompleteScreenState extends State<VocabularyCompleteScreen>
    with TickerProviderStateMixin {
  static const int _particleCount = 55;
  late AnimationController _controller;
  late List<_ConfettiParticle> _particles;
  final Random _random = Random();
  int? _pointsEarned;
  List<String> _newBadgeIds = [];
  bool _recorded = false;

  void _recordProgress(BuildContext context) {
    if (_recorded) return;
    _recorded = true;
    final progress = Provider.of<ProgressState>(context, listen: false);
    final newBadges = progress.recordFlashcardSetCompleted();
    if (mounted) {
      setState(() {
        _pointsEarned = kPointsPerFlashcardSet;
        _newBadgeIds = newBadges;
      });
    }
  }

  static const List<Color> _colors = [
    Color(0xFFE53935), // red
    Color(0xFFFB8C00), // orange
    Color(0xFFFDD835), // yellow
    Color(0xFF43A047), // green
    Color(0xFF1E88E5), // blue
    Color(0xFF8E24AA), // purple
    Color(0xFFEC407A), // pink
    Color(0xFF26A69A), // teal
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _particles = List.generate(_particleCount, (_) => _randomParticle());
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _ConfettiParticle _randomParticle() {
    return _ConfettiParticle(
      startX: _random.nextDouble(),
      delay: _random.nextDouble() * 0.5,
      color: _colors[_random.nextInt(_colors.length)],
      size: 6 + _random.nextDouble() * 10,
      aspect: 0.5 + _random.nextDouble() * 0.8,
      rotationSpeed: (_random.nextDouble() - 0.5) * 8,
      drift: (_random.nextDouble() - 0.5) * 0.15,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    WidgetsBinding.instance.addPostFrameCallback((_) => _recordProgress(context));

    return Scaffold(
      body: Stack(
        children: [
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.celebration_rounded,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'All done!',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You\'ve gone through all the vocabulary cards. Great job!',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_pointsEarned != null) ...[
                    const SizedBox(height: 20),
                    Semantics(
                      label: 'You earned $_pointsEarned points',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_rounded, size: 22, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'You earned +$_pointsEarned points',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_newBadgeIds.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ..._newBadgeIds.map((id) {
                      final a = Achievement.byId(id);
                      if (a == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(a.icon, size: 24, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'New badge: ${a.name}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.go('/'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: const Text('Back to home'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/generate-vocabulary'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: const Text('Practice more'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Confetti overlay (ignore pointer so buttons stay tappable)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _controller.value,
                    viewportSize: size,
                  ),
                  size: size,
                );
              },
            ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  _ConfettiParticle({
    required this.startX,
    required this.delay,
    required this.color,
    required this.size,
    required this.aspect,
    required this.rotationSpeed,
    required this.drift,
  });

  final double startX;
  final double delay;
  final Color color;
  final double size;
  final double aspect;
  final double rotationSpeed;
  final double drift;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.viewportSize,
  });

  final List<_ConfettiParticle> particles;
  final double progress;
  final Size viewportSize;

  @override
  void paint(Canvas canvas, Size size) {
    final w = viewportSize.width;
    final h = viewportSize.height;

    for (final p in particles) {
      final t = (progress - p.delay) / (1.0 - p.delay).clamp(0.001, 1.0);
      if (t <= 0) continue;

      // Fall from top with easing (starts fast, slows at end)
      final fallProgress = 1 - pow(1 - t, 1.2).toDouble();
      final y = -30 + fallProgress * (h + 80);
      final x = w * p.startX + fallProgress * p.drift * w;

      final rotation = fallProgress * pi * 2 * p.rotationSpeed;
      final rectW = p.size * (1 + p.aspect);
      final rectH = p.size * 0.7;
      final rect = Rect.fromCenter(
        center: Offset(x, y),
        width: rectW,
        height: rectH,
      );

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.translate(-x, -y);
      canvas.drawRect(
        rect,
        Paint()
          ..color = p.color
          ..style = PaintingStyle.fill,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
