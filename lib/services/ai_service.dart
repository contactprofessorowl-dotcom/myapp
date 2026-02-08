import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../quiz_state.dart';
import '../vocabulary_state.dart';

/// Centralized service for all AI (Gemini) features using Firebase AI Logic.
///
/// The API key is NOT stored in the app. Configure the Gemini API in the
/// [Firebase Console](https://firebase.google.com/docs/ai-logic/get-started):
/// Firebase AI Logic → Get started → set up Gemini Developer API.
/// Do not add the Gemini API key to your app codebase.
class AiService {
  AiService() : _model = _createModel();

  static GenerativeModel? _createModel() {
    try {
      return FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash',
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 8192,
          responseMimeType: 'application/json',
        ),
      );
    } catch (_) {
      return null;
    }
  }

  final GenerativeModel? _model;

  bool get isAvailable => _model != null;

  /// Generate quiz questions using Gemini. Adapts to age and expertise level.
  /// Returns fallback list if Firebase AI is unavailable or request fails.
  Future<List<Question>> generateQuestions({
    required String topic,
    String? age,
    required String expertiseLevel,
    int count = 5,
  }) async {
    if (_model == null) {
      if (kDebugMode) debugPrint('[AiService] No model (Firebase AI not configured). Using fallback questions.');
      return _fallbackQuestions(topic);
    }

    final ageContext = _buildAgeContext(age);
    final levelContext = _expertisePrompt(expertiseLevel);

    final prompt = '''
You are a quiz generator for an educational app. Generate exactly $count multiple-choice questions on the topic: "$topic".

$ageContext
$levelContext

Rules (follow strictly):
1. Each question must have exactly 4 answer options that are real, specific to the topic, and plausible. One option is correct; the other three are wrong but believable distractors.
2. "correctAnswerIndex" is the 0-based index (0, 1, 2, or 3) of the CORRECT option in the "options" array. So if the correct answer is the second option, use 1.
3. "hint" must be a short, helpful explanation that teaches the user why the correct answer is right and helps them understand the topic (so they learn when they get it wrong).

Output ONLY a valid JSON array. No markdown, no extra text. Each object:
- "question": string (clear question about the topic)
- "options": array of exactly 4 strings (the four answer choices; the one at index correctAnswerIndex is the right answer)
- "correctAnswerIndex": number (0, 1, 2, or 3)
- "hint": string (explanation to help the user learn)

Example (real content):
[{"question":"What is the capital of France?","options":["London","Berlin","Paris","Madrid"],"correctAnswerIndex":2,"hint":"Paris is the capital and largest city of France."},{"question":"Which country is the Eiffel Tower in?","options":["Belgium","France","Italy","Spain"],"correctAnswerIndex":1,"hint":"The Eiffel Tower is in Paris, France."}]
''';

    try {
      if (kDebugMode) debugPrint('[AiService] Calling Gemini for topic: $topic');
      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        if (kDebugMode) debugPrint('[AiService] Empty response from Gemini. Using fallback.');
        return _fallbackQuestions(topic);
      }

      var jsonStr = text;
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr
            .replaceFirst(RegExp(r'^```\w*\n?'), '')
            .replaceFirst(RegExp(r'\n?```\s*$'), '');
      }

      final list = jsonDecode(jsonStr) as List<dynamic>;
      final questions = <Question>[];
      for (final e in list) {
        final map = e as Map<String, dynamic>;
        final q = (map['question'] as String?)?.trim();
        final optsRaw = map['options'];
        final hint = (map['hint'] as String?)?.trim();
        if (q == null || q.isEmpty || hint == null || hint.isEmpty) continue;
        if (optsRaw is! List || optsRaw.length != 4) continue;
        final options = optsRaw.map((o) => o.toString().trim()).where((s) => s.isNotEmpty).toList();
        if (options.length != 4) continue;
        final idxRaw = map['correctAnswerIndex'] ?? map['correct_index'];
        int correctIndex = 0;
        if (idxRaw is int) {
          correctIndex = idxRaw.clamp(0, 3);
        } else if (idxRaw is double) {
          correctIndex = idxRaw.toInt().clamp(0, 3);
        }
        questions.add(Question(
          question: q,
          options: options,
          correctAnswerIndex: correctIndex,
          hint: hint,
        ));
      }
      if (questions.isEmpty) {
        if (kDebugMode) debugPrint('[AiService] Parsed 0 questions (invalid JSON shape). Response length: ${text.length}. Using fallback.');
        return _fallbackQuestions(topic);
      }
      if (kDebugMode) debugPrint('[AiService] Parsed ${questions.length} questions from Gemini.');
      return questions;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[AiService] Error: $e');
        debugPrint('[AiService] Stack: $st');
      }
      return _fallbackQuestions(topic);
    }
  }

  String _buildAgeContext(String? ageStr) {
    if (ageStr == null || ageStr.isEmpty) {
      return 'Audience: general. Use clear language and difficulty suitable for teens and adults.';
    }
    final age = int.tryParse(ageStr.trim());
    if (age == null) {
      return 'The user age is "$ageStr". Use age-appropriate content and difficulty.';
    }
    if (age >= 18) {
      return 'The user is an adult (age $age). Do NOT use content for young children: no questions on colors, basic shapes (e.g. how many sides/angles a shape has), simple counting, or preschool topics. Use depth, vocabulary, and difficulty appropriate for an adult. Match the expertise level for how challenging the questions are.';
    }
    if (age >= 13) {
      return 'The user is a teenager (age $age). Use teen-appropriate topics and vocabulary. Avoid very childish content (e.g. basic colors, "how many angles in a square").';
    }
    return 'The user is about $age years old. Use age-appropriate language and topics (simpler vocabulary and concepts are fine for younger users).';
  }

  String _expertisePrompt(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 'Difficulty: beginner. Simple facts, basic vocabulary.';
      case 'advanced':
        return 'Difficulty: advanced. Challenging questions, nuanced answers.';
      default:
        return 'Difficulty: intermediate. Mix of straightforward and thought-provoking.';
    }
  }

  List<Question> _fallbackQuestions(String topic) {
    return [
      Question(
        question: 'What is the main idea of "$topic"?',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correctAnswerIndex: 0,
        hint: 'Review the key concepts of $topic.',
      ),
      Question(
        question: 'Which of these best relates to $topic?',
        options: ['First choice', 'Second choice', 'Third choice', 'Fourth choice'],
        correctAnswerIndex: 1,
        hint: 'Consider how each option connects to $topic.',
      ),
    ];
  }

  /// Generate vocabulary flashcards for a topic. Each card has a definition (side A) and a term, 1–2 words (side B).
  /// Returns fallback list if Firebase AI is unavailable or request fails.
  Future<List<VocabularyCard>> generateVocabulary({
    required String topic,
    String? age,
    required String expertiseLevel,
    int count = 10,
  }) async {
    if (_model == null) {
      if (kDebugMode) debugPrint('[AiService] No model (Firebase AI not configured). Using fallback vocabulary.');
      return _fallbackVocabulary(topic);
    }

    final ageContext = _buildAgeContext(age);
    final levelContext = _expertisePrompt(expertiseLevel);

    final prompt = '''
You are a vocabulary flashcard generator for an educational app. Generate exactly $count flashcard items on the topic: "$topic".

$ageContext
$levelContext

Each card has two sides:
- Side A (definition): A clear definition, description, or detail—one or two sentences.
- Side B (term): The word or short phrase (1 or 2 words) that matches the definition.

Output ONLY a valid JSON array. No markdown, no extra text. Each object must have:
- "definition": string (the definition or detail for side A)
- "term": string (the word or 1–2 word phrase for side B)

Example:
[{"definition":"The capital and largest city of France.","term":"Paris"},{"definition":"A large structure in Paris, built for the 1889 World's Fair.","term":"Eiffel Tower"}]
''';

    try {
      if (kDebugMode) debugPrint('[AiService] Calling Gemini for vocabulary topic: $topic');
      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        if (kDebugMode) debugPrint('[AiService] Empty response. Using fallback vocabulary.');
        return _fallbackVocabulary(topic);
      }

      var jsonStr = text;
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr
            .replaceFirst(RegExp(r'^```\w*\n?'), '')
            .replaceFirst(RegExp(r'\n?```\s*$'), '');
      }

      final list = jsonDecode(jsonStr) as List<dynamic>;
      final cards = <VocabularyCard>[];
      for (final e in list) {
        final map = e as Map<String, dynamic>;
        final definition = (map['definition'] as String?)?.trim();
        final term = (map['term'] as String?)?.trim();
        if (definition == null || definition.isEmpty || term == null || term.isEmpty) continue;
        cards.add(VocabularyCard(term: term, definition: definition));
      }
      if (cards.isEmpty) {
        if (kDebugMode) debugPrint('[AiService] Parsed 0 vocabulary cards. Using fallback.');
        return _fallbackVocabulary(topic);
      }
      if (kDebugMode) debugPrint('[AiService] Parsed ${cards.length} vocabulary cards.');
      return cards;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[AiService] Error: $e');
        debugPrint('[AiService] Stack: $st');
      }
      return _fallbackVocabulary(topic);
    }
  }

  List<VocabularyCard> _fallbackVocabulary(String topic) {
    return [
      VocabularyCard(definition: 'The main subject or theme of "$topic".', term: 'Core concept'),
      VocabularyCard(definition: 'A key idea or term used when studying $topic.', term: 'Key term'),
      VocabularyCard(definition: 'Something you should remember about $topic.', term: 'Important point'),
    ];
  }
}
