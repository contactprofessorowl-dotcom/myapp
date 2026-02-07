import 'package:flutter/material.dart';

class QuizState with ChangeNotifier {
  int _score = 0;
  int get score => _score;

  final List<Map<String, Object>> _questions = const [
    {
      'questionText': 'What is the capital of France?',
      'answers': [
        {'text': 'Berlin', 'score': 0},
        {'text': 'Madrid', 'score': 0},
        {'text': 'Paris', 'score': 1},
        {'text': 'Rome', 'score': 0},
      ],
    },
    {
      'questionText': 'What is the largest planet in our solar system?',
      'answers': [
        {'text': 'Earth', 'score': 0},
        {'text': 'Jupiter', 'score': 1},
        {'text': 'Mars', 'score': 0},
        {'text': 'Venus', 'score': 0},
      ],
    },
  ];

  List<Map<String, Object>> get questions => _questions;

  void answerQuestion(int score) {
    _score += score;
    notifyListeners();
  }

  void resetQuiz() {
    _score = 0;
    notifyListeners();
  }
}
