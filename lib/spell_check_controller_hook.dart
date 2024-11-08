import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_levenshtein_distance_spell_check_demo/spell_check_controller.dart';

SpellCheckController useSpellCheckController({
  Locale locale = const Locale('en'),
}) =>
    use(_SpellCheckControllerHook(locale: locale));

class _SpellCheckControllerHook extends Hook<SpellCheckController> {
  const _SpellCheckControllerHook({this.locale = const Locale('en')});
  final Locale locale;

  @override
  _SpellCheckControllerHookState createState() =>
      _SpellCheckControllerHookState();
}

class _SpellCheckControllerHookState
    extends HookState<SpellCheckController, _SpellCheckControllerHook> {
  late final SpellCheckController controller;

  @override
  void initHook() {
    super.initHook();
    controller = SpellCheckController(locale: hook.locale);
  }

  @override
  SpellCheckController build(BuildContext context) => controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
