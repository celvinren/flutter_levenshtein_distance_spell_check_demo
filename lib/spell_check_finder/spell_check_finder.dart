import 'package:flutter_levenshtein_distance_spell_check_demo/models/mistake.dart';

export 'spell_check_finder_stud.dart'
    if (dart.library.io) 'spell_check_finder_mobile.dart'
    if (dart.library.html) 'spell_check_finder_web.dart';

typedef SpellCheckResult = ({
  List<Mistake> newMistakes,
  Set<String> newCheckedWords
});
