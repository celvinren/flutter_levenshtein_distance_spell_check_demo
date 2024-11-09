import 'dart:async';
import 'dart:js' as js;
import 'dart:js_util' as js_util;

import 'package:flutter_levenshtein_distance_spell_check_demo/models/mistake.dart';
import 'package:flutter_levenshtein_distance_spell_check_demo/spell_check_finder/result.dart';

class SpellCheckFinder {
  final StreamController<SpellCheckResult> _controller =
      StreamController<SpellCheckResult>();

  SpellCheckFinder() {
    _startListening();
  }

  Stream<SpellCheckResult> get stream => _controller.stream;

  void _startListening() {
    js.context['resultEmitter'].callMethod('addEventListener', [
      'newResult',
      js.allowInterop((event) {
        // Retrieve the JavaScript object and convert it to a Dart map
        final jsResult = js_util.getProperty(event, 'detail');
        // final text = js_util.getProperty(jsResult, 'text');
        final newMistakesJS =
            List<dynamic>.from(js_util.getProperty(jsResult, 'newMistakes'));
        final newMistakes = newMistakesJS.map((e) {
          // debugPrint('Mistake: $e');
          // final test = js_util.getProperty(e, 'length');
          // debugPrint('Test: $test');
          return Mistake.fromJson({
            'offset': js_util.getProperty(e, 'offset'),
            'length': js_util.getProperty(e, 'length'),
            'suggestions':
                List<String>.from(js_util.getProperty(e, 'suggestions')),
          });
        }).toList();

        final newCheckedWords =
            List<String>.from(js_util.getProperty(jsResult, 'newCheckedWords'));
        // debugPrint('results: $text');
        // debugPrint('Dictionary: $mistakeList');
        // debugPrint('results: $results');
        // debugPrint('Checked Words: $checkedWords');
        // final dartResult = _jsObjectToMap(jsResult);
        _controller.add((
          newMistakes: newMistakes,
          newCheckedWords: newCheckedWords.toSet()
        ));
      })
    ]);
  }

  Future<void> findMistakes({
    required String text,
    required List<String> dictionary,
    required Set<String> checkedWords,
  }) async {
    final jsDictionary = js.JsObject.jsify(dictionary);
    final jsCheckedWords = js.JsObject.jsify(checkedWords.toList());
    js.context.callMethod('postMessageToFindMistakesWorker',
        [text, jsDictionary, jsCheckedWords]);
  }

  void dispose() {
    _controller.close();
  }
}
