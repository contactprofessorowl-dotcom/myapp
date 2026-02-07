import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'quiz_state.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
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
    final quizState = Provider.of<QuizState>(context);
    final questions = quizState.questions;
    final questionCount = questions.length;

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: Text('No questions available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _showExitConfirmation(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Score: ${quizState.score}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _ProgressBar(
            currentPage: _currentPage,
            total: questionCount,
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: questionCount,
              itemBuilder: (context, index) {
                return Flashcard(
                  question: questions[index],
                  questionNumber: index + 1,
                  totalQuestions: questionCount,
                  pageController: _pageController,
                  isLastQuestion: index == questionCount - 1,
                );
              },
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
        title: const Text('Leave quiz?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to exit?',
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

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.currentPage,
    required this.total,
  });

  final int currentPage;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (currentPage + 1) / total : 0.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Question ${currentPage + 1} of $total',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Flashcard extends StatefulWidget {
  final Question question;
  final int questionNumber;
  final int totalQuestions;
  final PageController pageController;
  final bool isLastQuestion;

  const Flashcard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.pageController,
    required this.isLastQuestion,
  });

  @override
  State<Flashcard> createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleFlip() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  void _handleAnswer(int selectedIndex, BuildContext context) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = selectedIndex;
    });

    final isCorrect = selectedIndex == widget.question.correctAnswerIndex;
    Provider.of<QuizState>(context, listen: false).answerQuestion(isCorrect ? 1 : 0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(isCorrect ? 'Correct!' : 'Not quite — check the hint on the back!'),
          ],
        ),
        backgroundColor: isCorrect ? const Color(0xFF0D7377) : const Color(0xFFB00020),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    final router = GoRouter.of(context);
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      if (!widget.isLastQuestion) {
        widget.pageController.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        router.go('/results');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _handleFlip,
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
                ? _buildCardFace(theme, isFront: true)
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildCardFace(theme, isFront: false),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardFace(ThemeData theme, {required bool isFront}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Card(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isFront ? 'Tap card to see hint' : 'Tap to see question',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (isFront)
                    Icon(Icons.lightbulb_outline_rounded,
                        size: 20, color: theme.colorScheme.primary),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                isFront ? widget.question.question : widget.question.hint,
                style: theme.textTheme.headlineSmall?.copyWith(
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              if (isFront) ...[
                const SizedBox(height: 28),
                ...List.generate(widget.question.options.length, (index) {
                  final isCorrect = index == widget.question.correctAnswerIndex;
                  final isSelected = index == _selectedAnswerIndex;
                  final showResult = _isAnswered && (isSelected || isCorrect);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isAnswered
                            ? null
                            : () => _handleAnswer(index, context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: showResult
                                  ? (isCorrect
                                      ? const Color(0xFF0D7377)
                                      : const Color(0xFFB00020))
                                  : theme.colorScheme.outlineVariant,
                              width: showResult ? 2.5 : 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: showResult && isCorrect
                                ? const Color(0xFF0D7377).withValues(alpha: 0.12)
                                : showResult && isSelected && !isCorrect
                                    ? const Color(0xFFB00020).withValues(alpha: 0.08)
                                    : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                showResult
                                    ? (isCorrect
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded)
                                    : Icons.radio_button_unchecked_rounded,
                                size: 24,
                                color: showResult
                                    ? (isCorrect
                                        ? const Color(0xFF0D7377)
                                        : const Color(0xFFB00020))
                                    : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  widget.question.options[index],
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                if (widget.isLastQuestion && _isAnswered) ...[
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go('/results'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text('See results'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
