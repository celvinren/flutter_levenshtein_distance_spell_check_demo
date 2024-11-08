import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_levenshtein_distance_spell_check_demo/en.dart';
import 'package:flutter_levenshtein_distance_spell_check_demo/es.dart';
import 'package:flutter_levenshtein_distance_spell_check_demo/models/mistake.dart';

/// Spelling checker controller that extends TextEditingController
class SpellCheckController extends TextEditingController {
  List<Mistake> mistakes = [];
  Timer? timer;
  final Locale locale;
  final Set<String> checkedWords = {}; // Set to store checked words

  SpellCheckController({this.locale = const Locale('en')})
      : assert(locale == const Locale('en') || locale == const Locale('es'),
            'Only English and Spanish are supported');

  /// Handles spelling check when text changes
  @override
  set value(TextEditingValue newValue) {
    super.value = newValue;

    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 600), () {
      _checkSpelling(newValue.text);
    });
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    List<TextSpan> spans = [];
    // Start position for each segment of text
    int start = 0;

    for (final mistake in mistakes) {
      // Add text before the mistake (non-error part)
      if (start < mistake.offset) {
        spans.add(TextSpan(
          text: text.substring(start, mistake.offset),
          style: style,
        ));
      }

      // Add the mistake text with underline decoration
      spans.add(
        TextSpan(
          text: text.substring(mistake.offset, mistake.offset + mistake.length),
          style: style?.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: Colors.red,
            decorationStyle: TextDecorationStyle.wavy,
          ),
          recognizer: TapGestureRecognizer()
            ..onTapDown = (details) {
              _showSuggestionsOverlay(
                context: context,
                items: [
                  const PopupMenuItem(
                    enabled: false,
                    child: Text('Replace with:'),
                  ),
                  ...mistake.suggestions
                      .map<PopupMenuItem<VoidCallback>>((suggestion) {
                    return PopupMenuItem(
                      value: () => _replaceMistake(mistake, suggestion),
                      child: Text(suggestion),
                    );
                  }).toList(),
                ],
              );
            },
        ),
      );

      // Update the start to be after the current mistake
      start = mistake.offset + mistake.length;
    }

    // Add remaining text after the last mistake
    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: style,
        ),
      );
    }

    return TextSpan(children: spans);
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

  /// Checks spelling and generates suggestions
  void _checkSpelling(String text) {
    // Find new mistakes
    mistakes = [
      ...mistakes,
      ..._findMistakes(text)
          .map((e) => mistakes.contains(e) ? null : e)
          .where((e) => e != null)
          .cast<Mistake>(),
    ]..sort((a, b) => a.offset.compareTo(b.offset));
    notifyListeners();
  }

  List<Mistake> _findMistakes(String text) {
    List<Mistake> results = [];

    // Select dictionary based on language
    final words = locale.languageCode == 'en' ? enWords1 : esWords1;
    final dictionary = words.split('\n');

    // Split the text into sentences based on punctuation
    final sentenceRegex = RegExp(r'[^.!?]+');
    final sentences = sentenceRegex.allMatches(text);

    for (final sentenceMatch in sentences) {
      final sentence = sentenceMatch.group(0)!;

      // Use regular expression to match words in each sentence
      final wordRegex = RegExp(r'\b\w+\b');
      final wordMatches = wordRegex.allMatches(sentence).toList();

      // Loop through each matched word within the sentence but skip the last one
      for (int j = 0; j < wordMatches.length - 1; j++) {
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
          results.add(
            Mistake(
              offset: sentenceMatch.start + match.start,
              length: word.length,
              suggestions: suggestions,
            ),
          );
        }

        // Add the word to the checked words set
        checkedWords.add(lowercasedWord);
      }
    }
    return results;
  }

  /// Replaces the mistake with the selected suggestion
  void _replaceMistake(Mistake mistake, String replacement) {
    if (text
        .substring(mistake.offset, mistake.offset + mistake.length)
        .startsWith(RegExp(r'[A-Z]'))) {
      // Capitalize the replacement if the original word is capitalized
      replacement = replacement[0].toUpperCase() + replacement.substring(1);
    }

    String newText = text.replaceRange(
      mistake.offset,
      mistake.offset + mistake.length,
      replacement,
    );

    // Calculate the difference in length between the mistake and the replacement
    int offsetDifference = replacement.length - mistake.length;

    value = TextEditingValue(
      text: newText,
      selection:
          TextSelection.collapsed(offset: mistake.offset + replacement.length),
    );

    // Adjust the offset of all mistakes after the current one
    for (int i = mistakes.indexOf(mistake) + 1; i < mistakes.length; i++) {
      mistakes[i] =
          mistakes[i].copyWith(offset: mistakes[i].offset + offsetDifference);
    }

    // Add the replacement to the checked words set
    checkedWords.add(replacement.toLowerCase());
    mistakes.remove(mistake);
    // notifyListeners();
  }

  _showSuggestionsOverlay({
    required BuildContext context,
    required List<PopupMenuEntry<VoidCallback>> items,
    GlobalKey? atWidget,
  }) {
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    final RenderBox button = atWidget == null
        ? context.findRenderObject()! as RenderBox
        : atWidget.currentContext!.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final Offset offset = Offset(0.0, button.size.height);
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(offset, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero) + offset,
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    // Only show the menu if there is something to show
    if (items.isNotEmpty) {
      showMenu<VoidCallback?>(
        context: context,
        elevation: popupMenuTheme.elevation,
        items: items,
        position: position,
        shape: popupMenuTheme.shape,
        color: popupMenuTheme.color,
      ).then<void>((VoidCallback? newValue) {
        newValue?.call();
      });
    }
  }
}
