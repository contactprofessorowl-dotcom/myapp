import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'quiz_state.dart';

// A data class for the questions
class Question {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String hint;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.hint,
  });
}

// Dummy data for now
final List<Question> dummyQuestions = [
  Question(
    question: 'What is the capital of France?',
    options: ['Berlin', 'Madrid', 'Paris', 'Rome'],
    correctAnswerIndex: 2,
    hint: 'It is known as the city of love.',
  ),
  Question(
    question: 'What is 2 + 2?',
    options: ['3', '4', '5', '6'],
    correctAnswerIndex: 1,
    hint: 'It is a simple addition.',
  ),
  Question(
    question: 'Who wrote "To Kill a Mockingbird"?',
    options: [
      'Harper Lee',
      'Mark Twain',
      'J.K. Rowling',
      'F. Scott Fitzgerald',
    ],
    correctAnswerIndex: 0,
    hint: 'The author is a woman.',
  ),
];

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        actions: [
          Consumer<QuizState>(
            builder: (context, quizState, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(child: Text('Score: ${quizState.score}')),
              );
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        // physics: const NeverScrollableScrollPhysics(), // Uncomment to disable swipe
        itemCount: dummyQuestions.length,
        itemBuilder: (context, index) {
          return Flashcard(
            question: dummyQuestions[index],
            pageController: _pageController,
            isLastQuestion: index == dummyQuestions.length - 1,
          );
        },
      ),
    );
  }
}

class Flashcard extends StatefulWidget {
  final Question question;
  final PageController pageController;
  final bool isLastQuestion;

  const Flashcard({
    super.key,
    required this.question,
    required this.pageController,
    required this.isLastQuestion,
  });

  @override
  State<Flashcard> createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFlipped = false;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _handleAnswer(int selectedIndex, BuildContext context) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = selectedIndex;
    });

    final isCorrect = selectedIndex == widget.question.correctAnswerIndex;
    Provider.of<QuizState>(
      context,
      listen: false,
    ).answerQuestion(isCorrect ? 1 : 0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Correct!' : 'Wrong!'),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );

    // Wait for a moment before moving to the next card or finishing the quiz
    Timer(const Duration(seconds: 2), () {
      if (!widget.isLastQuestion) {
        widget.pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        context.go('/results');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
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
                ? _buildCardFace(isFront: true)
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildCardFace(isFront: false),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardFace({required bool isFront}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(24),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isFront ? widget.question.question : widget.question.hint,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              if (isFront) ...[
                const SizedBox(height: 20),
                ...List.generate(widget.question.options.length, (index) {
                  return RadioListTile<int>(
                    title: Text(widget.question.options[index]),
                    value: index,
                    groupValue: _selectedAnswerIndex,
                    onChanged: (value) => _handleAnswer(value!, context),
                    activeColor: _isAnswered
                        ? (index == widget.question.correctAnswerIndex
                              ? Colors.green
                              : Colors.red)
                        : Theme.of(context).primaryColor,
                  );
                }),
                if (widget.isLastQuestion && _isAnswered)
                  ElevatedButton(
                    onPressed: () {
                      context.go('/results');
                    },
                    child: const Text('Finish Quiz'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
