import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'quiz_state.dart';

// Minimum height for question area (~5 lines at bodyLarge)
const double _kQuestionSectionMinHeight = 200;

// Width above which options show in 2 columns (tablets, landscape)
const double _kTwoColumnBreakpoint = 600;

// High-contrast colors for accessibility (WCAG AA+)
const Color _kCorrectColor = Color(0xFF0D7377);
const Color _kIncorrectColor = Color(0xFFB00020);

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  late List<bool> _pageAnswered;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageAnswered = [];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageAnswered(int index, int score) {
    Provider.of<QuizState>(context, listen: false).answerQuestion(score);
    if (index >= 0 && index < _pageAnswered.length) {
      setState(() => _pageAnswered[index] = true);
    }
  }

  void _goToPrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    final quizState = Provider.of<QuizState>(context, listen: false);
    final questionCount = quizState.questionCount;
    if (_currentPage < questionCount - 1) {
      if (!_pageAnswered[_currentPage]) {
        _onPageAnswered(_currentPage, 0);
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      if (!_pageAnswered[_currentPage]) {
        _onPageAnswered(_currentPage, 0);
      }
      context.go('/results');
    }
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

    if (_pageAnswered.length != questionCount) {
      _pageAnswered = List.filled(questionCount, false);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        leading: Semantics(
          label: 'Close quiz. Your progress will be lost.',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => _showExitConfirmation(context),
            tooltip: 'Close quiz',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Semantics(
                label: 'Current score: ${quizState.score} correct',
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
                return _QuizPlayerPage(
                  question: questions[index],
                  questionNumber: index + 1,
                  totalQuestions: questionCount,
                  isAnswered: _pageAnswered[index],
                  onAnswered: (score) => _onPageAnswered(index, score),
                  isLastQuestion: index == questionCount - 1,
                );
              },
            ),
          ),
          _QuizBottomBar(
            currentPage: _currentPage,
            total: questionCount,
            onPrevious: _goToPrevious,
            onNext: _goToNext,
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

/// Fixed bottom bar: Previous | Next (or See results on last question).
class _QuizBottomBar extends StatelessWidget {
  const _QuizBottomBar({
    required this.currentPage,
    required this.total,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int total;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFirst = currentPage == 0;
    final isLast = currentPage == total - 1;

    return Semantics(
      label: isLast ? 'Navigation: Previous question or See results' : 'Navigation: Previous question or Next question',
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  label: isFirst ? null : 'Previous question',
                  enabled: !isFirst,
                  child: OutlinedButton(
                    onPressed: isFirst ? null : onPrevious,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Previous'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Semantics(
                  label: isLast ? 'See results' : 'Next question',
                  child: FilledButton(
                    onPressed: onNext,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(isLast ? 'See results' : 'Next'),
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
    final theme = Theme.of(context);
    return Semantics(
      label: 'Question ${currentPage + 1} of $total',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${currentPage + 1} of $total',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One full page per question: top = question flashcard, bottom = options.
/// Navigation is handled by the fixed bottom bar in QuizScreen.
class _QuizPlayerPage extends StatefulWidget {
  final Question question;
  final int questionNumber;
  final int totalQuestions;
  final bool isAnswered;
  final void Function(int score) onAnswered;
  final bool isLastQuestion;

  const _QuizPlayerPage({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.isAnswered,
    required this.onAnswered,
    required this.isLastQuestion,
  });

  @override
  State<_QuizPlayerPage> createState() => _QuizPlayerPageState();
}

class _QuizPlayerPageState extends State<_QuizPlayerPage> {
  int? _selectedAnswerIndex;

  void _handleAnswer(int selectedIndex, BuildContext context) {
    if (widget.isAnswered) return;

    setState(() => _selectedAnswerIndex = selectedIndex);

    final isCorrect = selectedIndex == widget.question.correctAnswerIndex;
    widget.onAnswered(isCorrect ? 1 : 0);

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
            Flexible(
              child: Text(
                isCorrect
                    ? 'Correct!'
                    : 'Not quite — tap the question card to see the hint.',
              ),
            ),
          ],
        ),
        backgroundColor: isCorrect ? _kCorrectColor : _kIncorrectColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useTwoColumns = width >= _kTwoColumnBreakpoint;

    return LayoutBuilder(
      builder: (context, constraints) {
        final shortScreen = constraints.maxHeight < 500;
        final questionCard = Semantics(
          header: true,
          label: 'Question ${widget.questionNumber} of ${widget.totalQuestions}',
          child: _QuestionFlashcard(
            questionText: widget.question.question,
            hintText: widget.question.hint,
            questionNumber: widget.questionNumber,
            totalQuestions: widget.totalQuestions,
          ),
        );

        final optionsAndButton = [
          const SizedBox(height: 20),
          _OptionsSection(
            question: widget.question,
            selectedAnswerIndex: _selectedAnswerIndex,
            isAnswered: widget.isAnswered,
            onAnswer: _handleAnswer,
            useTwoColumns: useTwoColumns,
          ),
        ];

        if (shortScreen) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: _kQuestionSectionMinHeight,
                  child: questionCard,
                ),
                ...optionsAndButton,
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _kQuestionSectionMinHeight),
                  child: questionCard,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: _OptionsSection(
                    question: widget.question,
                    selectedAnswerIndex: _selectedAnswerIndex,
                    isAnswered: widget.isAnswered,
                    onAnswer: _handleAnswer,
                    useTwoColumns: useTwoColumns,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Top section: flip between question and hint. Tap to flip. High contrast.
class _QuestionFlashcard extends StatefulWidget {
  final String questionText;
  final String hintText;
  final int questionNumber;
  final int totalQuestions;

  const _QuestionFlashcard({
    required this.questionText,
    required this.hintText,
    required this.questionNumber,
    required this.totalQuestions,
  });

  @override
  State<_QuestionFlashcard> createState() => _QuestionFlashcardState();
}

class _QuestionFlashcardState extends State<_QuestionFlashcard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
    final textColor = theme.colorScheme.onSurface;
    final hintLabelColor = theme.colorScheme.onSurfaceVariant;

    return Semantics(
      label: _controller.value < 0.5
          ? 'Question. Double tap to show hint.'
          : 'Hint. Double tap to show question.',
      button: true,
      onTap: _flip,
      child: GestureDetector(
        onTap: _flip,
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
                      textColor: textColor,
                      hintLabelColor: hintLabelColor,
                      text: widget.questionText,
                      label: 'Tap to see hint',
                      icon: Icons.lightbulb_outline_rounded,
                    )
                  : Transform(
                      transform: Matrix4.identity()..rotateY(pi),
                      alignment: Alignment.center,
                      child: _buildFace(
                        theme: theme,
                        cardColor: cardColor,
                        textColor: textColor,
                        hintLabelColor: hintLabelColor,
                        text: widget.hintText,
                        label: 'Tap to see question',
                        icon: Icons.help_outline_rounded,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFace({
    required ThemeData theme,
    required Color cardColor,
    required Color textColor,
    required Color hintLabelColor,
    required String text,
    required String label,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: _kQuestionSectionMinHeight),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.25 : 0.06),
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
                    color: hintLabelColor,
                  ),
                ),
                Icon(icon, size: 22, color: theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    text,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: textColor,
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

/// Bottom section: answer options. High-contrast correct/incorrect states.
/// On wide screens (tablet, landscape), options lay out in 2 columns.
class _OptionsSection extends StatelessWidget {
  final Question question;
  final int? selectedAnswerIndex;
  final bool isAnswered;
  final void Function(int index, BuildContext context) onAnswer;
  final bool useTwoColumns;

  const _OptionsSection({
    required this.question,
    required this.selectedAnswerIndex,
    required this.isAnswered,
    required this.onAnswer,
    this.useTwoColumns = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final optionWidgets = List.generate(question.options.length, (index) {
      return _OptionTile(
        theme: theme,
        question: question,
        index: index,
        selectedAnswerIndex: selectedAnswerIndex,
        isAnswered: isAnswered,
        onAnswer: onAnswer,
      );
    });

    return Semantics(
      label: 'Answer options',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose an answer:',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (useTwoColumns) ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final half = (question.options.length + 1) ~/ 2;
                final left = optionWidgets.sublist(0, half);
                final right = optionWidgets.sublist(half);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: left,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: right,
                      ),
                    ),
                  ],
                );
              },
            ),
          ] else
            ...optionWidgets,
        ],
      ),
    );
  }

}

/// Single option tile (used in 1-column and 2-column layouts).
class _OptionTile extends StatelessWidget {
  final ThemeData theme;
  final Question question;
  final int index;
  final int? selectedAnswerIndex;
  final bool isAnswered;
  final void Function(int index, BuildContext context) onAnswer;

  const _OptionTile({
    required this.theme,
    required this.question,
    required this.index,
    required this.selectedAnswerIndex,
    required this.isAnswered,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = index == question.correctAnswerIndex;
    final isSelected = index == selectedAnswerIndex;
    final showResult = isAnswered && (isSelected || isCorrect);
    final correctStyle = showResult && isCorrect;
    final incorrectStyle = showResult && isSelected && !isCorrect;

    Color borderColor() {
      if (correctStyle) return _kCorrectColor;
      if (incorrectStyle) return _kIncorrectColor;
      return theme.colorScheme.outline;
    }

    Color? backgroundColor() {
      if (correctStyle) return _kCorrectColor.withValues(alpha: 0.15);
      if (incorrectStyle) return _kIncorrectColor.withValues(alpha: 0.12);
      return null;
    }

    IconData icon() {
      if (correctStyle) return Icons.check_circle_rounded;
      if (incorrectStyle) return Icons.cancel_rounded;
      return Icons.radio_button_unchecked_rounded;
    }

    Color iconColor() {
      if (correctStyle) return _kCorrectColor;
      if (incorrectStyle) return _kIncorrectColor;
      return theme.colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        enabled: !isAnswered,
        label: 'Option ${index + 1}: ${question.options[index]}'
            '${showResult ? (isCorrect ? '. Correct.' : '. Incorrect.') : ''}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isAnswered ? null : () => onAnswer(index, context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor(), width: showResult ? 3 : 2),
                borderRadius: BorderRadius.circular(20),
                color: backgroundColor(),
              ),
              child: Row(
                children: [
                  Icon(icon(), size: 26, color: iconColor()),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      question.options[index],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight:
                            showResult ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
