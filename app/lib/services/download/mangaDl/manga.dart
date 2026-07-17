// =============================================================================
// mangodl_flutter — Educational Flutter port of mangodl-nodejs.
// See lib/parsers/base.dart for the project-wide disclaimer.
// =============================================================================

// -----------------------------------------------------------------------------
// lib/main.dart — App entry point.
//
// Boots a MaterialApp with a single SearchPage. The whole UI is
// intentionally small: a search bar, a results grid, a chapter list,
// and a download button per chapter. This matches the JS version's
// "rudimentary GUI" mandate.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'parsers/registry.dart';
import 'ui/app_state.dart';
import 'ui/search_page.dart';

void main() {
  // Ensure the registry is initialized.
  // ignore: unused_local_variable
  final _ = ParserRegistry.all();

  runApp(const MangodlApp());
}

class MangodlApp extends StatelessWidget {
  const MangodlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MangodlAppState(),
      child: MaterialApp(
        title: 'mangodl-flutter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const SearchPage(),
      ),
    );
  }
}
