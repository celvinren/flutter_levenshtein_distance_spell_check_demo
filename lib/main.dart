import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_levenshtein_distance_spell_check_demo/spell_check_controller_hook.dart';

/// Main application
void main() {
  runApp(const MyApp());
}

class MyApp extends HookWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Spell Check Example")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: useSpellCheckController(locale: const Locale('en')),
                maxLines: 7,
              ),
              TextField(
                controller: useSpellCheckController(locale: const Locale('en')),
                maxLines: 7,
              ),
              TextField(
                controller: useSpellCheckController(locale: const Locale('en')),
                maxLines: 7,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
