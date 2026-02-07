import 'package:flutter/material.dart';

/// Single source of truth for quiz questions. Used by QuizScreen and ResultsScreen.
class Question {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String hint;

  const Question({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.hint,
  });
}

class QuizState with ChangeNotifier {
  int _score = 0;
  int get score => _score;

  static const List<Question> _defaultQuestions = [
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

  List<Question>? _generatedQuestions;

  List<Question> get questions => _generatedQuestions ?? _defaultQuestions;
  int get questionCount => questions.length;

  bool get hasGeneratedQuestions => _generatedQuestions != null;

  void setGeneratedQuestions(List<Question> q) {
    _generatedQuestions = q.isNotEmpty ? q : null;
    _score = 0;
    notifyListeners();
  }

  void clearGeneratedQuestions() {
    _generatedQuestions = null;
    _score = 0;
    notifyListeners();
  }

  void answerQuestion(int score) {
    _score += score;
    notifyListeners();
  }

  void resetQuiz() {
    _score = 0;
    notifyListeners();
  }
}
