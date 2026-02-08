import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'vocabulary_state.dart';

class VocabularyCardsScreen extends StatefulWidget {
  const VocabularyCardsScreen({super.key});

  @override
  State<VocabularyCardsScreen> createState() => _VocabularyCardsScreenState();
}

class _VocabularyCardsScreenState extends State<VocabularyCardsScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyState = Provider.of<VocabularyState>(context);
    final cards = vocabularyState.cards;
    final count = cards.length;

    if (count == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vocabulary')),
        body: const Center(
          child: Text('No flashcards. Generate a set from the home screen.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _showExitConfirmation(context),
          tooltip: 'Close',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Card ${_currentPage + 1} of $count',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: count > 0 ? (_currentPage + 1) / count : 0,
                    minHeight: 6,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: count,
              itemBuilder: (context, index) {
                return _VocabularyFlashcard(card: cards[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Swipe left or right to change card',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _currentPage == 0
                          ? null
                          : () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                              );
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () {
                        if (_currentPage >= count - 1) {
                          context.go('/vocabulary-complete');
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_currentPage >= count - 1 ? 'Done' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave flashcards?'),
        content: const Text(
          'You can start a new set from the home screen anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/');
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

/// Single flashcard: tap to flip between definition (side A) and term (side B).
class _VocabularyFlashcard extends StatefulWidget {
  const _VocabularyFlashcard({required this.card});

  final VocabularyCard card;

  @override
  State<_VocabularyFlashcard> createState() => _VocabularyFlashcardState();
}

class _VocabularyFlashcardState extends State<_VocabularyFlashcard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  void _flip() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    return Semantics(
      label: _controller.value < 0.5
          ? 'Definition. Double tap to reveal answer.'
          : 'Term. Double tap to see definition.',
      button: true,
      onTap: _flip,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _flip,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = _controller.value * pi;
              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle);

              return Transform(
                transform: transform,
                alignment: Alignment.center,
                child: _controller.value < 0.5
                    ? _buildFace(
                        theme: theme,
                        cardColor: cardColor,
                        label: 'Definition',
                        text: widget.card.definition,
                        icon: Icons.description_rounded,
                        onSpeak: () => _speak(widget.card.definition),
                      )
                    : Transform(
                        transform: Matrix4.identity()..rotateY(pi),
                        alignment: Alignment.center,
                        child: _buildFace(
                          theme: theme,
                          cardColor: cardColor,
                          label: 'Term',
                          text: widget.card.term,
                          icon: Icons.label_rounded,
                          onSpeak: () => _speak(widget.card.term),
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFace({
    required ThemeData theme,
    required Color cardColor,
    required String label,
    required String text,
    required IconData icon,
    VoidCallback? onSpeak,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onSpeak != null)
                      Semantics(
                        label: 'Play text aloud',
                        button: true,
                        child: IconButton(
                          icon: Icon(
                            Icons.volume_up_rounded,
                            size: 24,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: onSpeak,
                          tooltip: 'Play audio',
                          style: IconButton.styleFrom(
                            minimumSize: const Size(44, 44),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    Icon(icon, size: 22, color: theme.colorScheme.primary),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    text,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
