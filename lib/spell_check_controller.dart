import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_levenshtein_distance_spell_check_demo/models/mistake.dart';
import 'package:flutter_levenshtein_distance_spell_check_demo/spell_check_finder/spell_check_finder.dart';

import 'en.dart';
import 'es.dart';

/// Spelling checker controller that extends TextEditingController
class SpellCheckController extends TextEditingController {
  List<Mistake> mistakes = [];
  Timer? timer;
  Locale locale = const Locale('en');
  Set<String> checkedWords = {}; // Set to store checked words
  final SpellCheckFinder spellCheckFinder = SpellCheckFinder();

  SpellCheckController({this.locale = const Locale('en')})
      : assert(locale == const Locale('en') || locale == const Locale('es'),
            'Only English and Spanish are supported') {
    spellCheckFinder.stream.listen((event) {
      mistakes = [
        ...mistakes,
        ...event.newMistakes.where((e) => !mistakes.contains(e)),
      ]..sort((a, b) => a.offset.compareTo(b.offset));
      checkedWords.addAll(event.newCheckedWords);
      notifyListeners();
    });
  }

  /// Handles spelling check when text changes
  @override
  set value(TextEditingValue newValue) {
    super.value = newValue;

    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 600), () {
      if (text.isNotEmpty) {
        spellCheckFinder.findMistakes(
          text: text,
          dictionary:
              (locale.languageCode == 'en' ? enWords1 : esWords1).split('\n'),
          checkedWords: checkedWords,
        );
      }
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
          recognizer: DoubleTapGestureRecognizer()
            ..onDoubleTapDown = (details) {
              _showSuggestionsOverlay(
                context: context,
                items: [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(mistake.suggestions.isNotEmpty
                        ? 'Replace with:'
                        : 'No suggestions'),
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

  @override
  void dispose() {
    timer?.cancel();
    spellCheckFinder.dispose();
    super.dispose();
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

    // Update the text value and selection
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
    checkedWords.remove(text
        .substring(mistake.offset, mistake.offset + mistake.length)
        .toLowerCase());
    mistakes.remove(mistake);
    // notifyListeners();
  }

  void _showSuggestionsOverlay({
    required BuildContext context,
    required List<PopupMenuEntry<VoidCallback>> items,
    GlobalKey? atWidget,
  }) {
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    final RenderBox widget = atWidget == null
        ? context.findRenderObject()! as RenderBox
        : atWidget.currentContext!.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final Offset offset = Offset(0.0, widget.size.height);
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        widget.localToGlobal(offset, ancestor: overlay),
        widget.localToGlobal(widget.size.bottomRight(Offset.zero) + offset,
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
