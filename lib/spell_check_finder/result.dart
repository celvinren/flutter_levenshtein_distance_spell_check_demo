import 'package:flutter_levenshtein_distance_spell_check_demo/models/mistake.dart';

typedef SpellCheckResult = ({
  List<Mistake> newMistakes,
  Set<String> newCheckedWords
});
