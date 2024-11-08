import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_levenshtein_distance_spell_check_demo/en.dart';
import 'package:flutter_levenshtein_distance_spell_check_demo/es.dart';

/// Spelling checker controller that extends TextEditingController
class SpellCheckController extends TextEditingController {
  List<Mistake> mistakes = [];
  OverlayEntry? _overlayEntry;
  Timer? timer;
  final Locale locale;

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
              _showSuggestionsOverlay(context, mistake);
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

    for (int i = 0; i < t.length + 1; i < i++) {
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
    // Clear previous mistakes and overlay
    mistakes.clear();
    try {
      _overlayEntry?.remove();
    } catch (e) {
      debugPrint(e.toString());
    }
    _overlayEntry = null;

    // Find new mistakes
    mistakes = _findMistakes(text);
    notifyListeners();
  }

  List<Mistake> _findMistakes(String text) {
    List<Mistake> mistakes = [];

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
          mistakes.add(
            Mistake(
              offset: sentenceMatch.start + match.start,
              length: word.length,
              suggestions: suggestions,
            ),
          );
        }
      }
    }
    return mistakes;
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

    value = TextEditingValue(
      text: newText,
      selection:
          TextSelection.collapsed(offset: mistake.offset + replacement.length),
    );

    mistakes.remove(mistake);
  }

  /// Shows suggestions overlay
  void _showSuggestionsOverlay(BuildContext context, Mistake mistake) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    try {
      _overlayEntry?.remove();
    } catch (e) {
      debugPrint(e.toString());
    }
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // This GestureDetector dismisses the overlay when tapping outside
            GestureDetector(
              onTap: () {
                _overlayEntry?.remove();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.transparent,
              ),
            ),
            Positioned(
              left: position.dx,
              top: position.dy + renderBox.size.height,
              child: Material(
                elevation: 4.0,
                child: _PopUpMenu(
                  mistake: mistake,
                  onReplace: (suggestion) {
                    _replaceMistake(mistake, suggestion);
                    _overlayEntry?.remove();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }
}

/// Mistake class to store misspelled words and their suggestions
class Mistake {
  final int offset;
  final int length;
  final List<String> suggestions;

  Mistake({
    required this.offset,
    required this.length,
    required this.suggestions,
  });
}

class _PopUpMenu extends StatelessWidget {
  const _PopUpMenu({required this.mistake, required this.onReplace});
  final Mistake mistake;
  final void Function(String suggestion) onReplace;

  @override
  Widget build(BuildContext context) {
    debugPrint(MediaQuery.of(context).size.height.toString());
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: SizedBox(
        height: MediaQuery.of(context).size.height < 560
            ? MediaQuery.of(context).size.height * 0.6
            : null,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: mistake.suggestions.isNotEmpty
                ? mistake.suggestions.map((suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                      onTap: () => onReplace(suggestion),
                    );
                  }).toList()
                : [const ListTile(title: Text("No suggestions"))],
          ),
        ),
      ),
    );
  }
}
