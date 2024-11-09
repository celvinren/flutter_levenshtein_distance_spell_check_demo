import 'dart:async';

import 'package:flutter_levenshtein_distance_spell_check_demo/spell_check_finder/result.dart';

class SpellCheckFinder {
  final StreamController<SpellCheckResult> _controller =
      StreamController<SpellCheckResult>();
  Stream<SpellCheckResult> get stream => _controller.stream;
  Future<void> findMistakes({
    required String text,
    required List<String> dictionary,
    required Set<String> checkedWords,
  }) async {}

  void dispose() {}
}
