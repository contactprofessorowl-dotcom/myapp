import 'package:flutter/material.dart';

/// A single vocabulary flashcard: definition/detail on one side, term (1–2 words) on the other.
class VocabularyCard {
  const VocabularyCard({
    required this.term,
    required this.definition,
  });

  /// The word or short phrase (1–2 words) shown on the answer side.
  final String term;

  /// The definition or detail shown on the question side.
  final String definition;
}

/// Holds the current vocabulary set for the flashcard flow.
class VocabularyState with ChangeNotifier {
  List<VocabularyCard> _cards = [];
  List<VocabularyCard> get cards => List.unmodifiable(_cards);
  int get cardCount => _cards.length;

  void setCards(List<VocabularyCard> cards) {
    _cards = cards.isNotEmpty ? List.from(cards) : [];
    notifyListeners();
  }

  void clearCards() {
    _cards = [];
    notifyListeners();
  }
}
