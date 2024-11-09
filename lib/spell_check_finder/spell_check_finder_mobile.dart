import 'dart:async';
import 'dart:math';

import 'package:flutter_levenshtein_distance_spell_check_demo/models/mistake.dart';
import 'package:flutter_levenshtein_distance_spell_check_demo/spell_check_finder/result.dart';

/// Spell checker class that uses Levenshtein distance to find mistakes
class SpellCheckFinder {
  final StreamController<SpellCheckResult> _controller =
      StreamController<SpellCheckResult>();

  Stream<SpellCheckResult> get stream => _controller.stream;

  void dispose() {
    _controller.close();
  }

  void findMistakes({
    required String text,
    required List<String> dictionary,
    required Set<String> checkedWords,
  }) {
    List<Mistake> newMistakes = [];
    Set<String> newCheckedWords = {};

    // Split the text into sentences based on punctuation
    final sentenceRegex = RegExp(r'[^.!?]+');
    final sentences = sentenceRegex.allMatches(text).toList();

    for (int i = 0; i < sentences.length; i++) {
      final sentence = sentences[i].group(0)!;

      // Use regular expression to match words in each sentence
      final wordRegex = RegExp(r'\b\w+\b');
      final wordMatches = wordRegex.allMatches(sentence).toList();

      // Loop through each matched word within the sentence but skip the last one
      for (int j = 0;
          j <
              ((i == sentences.length - 1)
                  ? wordMatches.length - 1
                  : wordMatches.length);
          j++) {
        final match = wordMatches[j];
        final word = match.group(0)!;
        final lowercasedWord = word.toLowerCase();

        // Skip if the word has already been checked
        if (checkedWords.contains(lowercasedWord)) {
          continue;
        }

        // Perform spell check if word is not in dictionary
        if (!dictionary.contains(lowercasedWord)) {
          bool isCapitalized = word[0].toUpperCase() == word[0];

          // Check if it might be a proper noun
          bool isPotentialProperNoun = isCapitalized && j > 0;
          // If it's the first word of a sentence, perform spell check, don't skip
          if (isPotentialProperNoun) {
            continue; // Skip the word if it's likely a proper noun in the middle of a sentence
          }

          // Calculate Levenshtein distance for all possible suggestions
          List<MapEntry<String, int>> potentialSuggestions = dictionary
              .map((entry) =>
                  MapEntry(entry, _levenshteinDistance(entry, lowercasedWord)))
              .where((entry) =>
                  entry.value <= 2) // Filter words with distance <= 2
              .toList();

          // Sort by distance and select the top 10
          potentialSuggestions.sort((a, b) => a.value - b.value);
          List<String> suggestions = potentialSuggestions
              .take(10)
              .map<String>((entry) => isCapitalized
                  ? (entry.key[0].toUpperCase() + entry.key.substring(1))
                  : entry.key)
              .toList();

          // Add to the list of mistakes with correct offset in the original text
          newMistakes.add(
            Mistake(
              offset: sentences[i].start + match.start,
              length: word.length,
              suggestions: suggestions,
            ),
          );
        }

        // Add the word to the checked words set
        newCheckedWords.add(lowercasedWord);
      }
    }
    _controller
        .add((newMistakes: newMistakes, newCheckedWords: newCheckedWords));
  }

  /// Levenshtein distance algorithm
  int _levenshteinDistance(String s, String t, {bool caseSensitive = false}) {
    if (!caseSensitive) {
      s = s.toLowerCase();
      t = t.toLowerCase();
    }
    if (s == t) {
      return 0;
    }
    if (s.isEmpty) {
      return t.length;
    }
    if (t.isEmpty) {
      return s.length;
    }

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < t.length + 1; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }

      for (int j = 0; j < t.length + 1; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[t.length];
  }
}
