// =============================================================================
// mangodl_flutter — Educational Flutter port of mangodl-nodejs.
// See lib/parsers/base.dart for the project-wide disclaimer.
// =============================================================================

// -----------------------------------------------------------------------------
// lib/ui/search_page.dart — The main page.
//
// Layout (left-to-right on wide screens, top-to-bottom on narrow):
//
//   ┌─────────────────────────────────────────────┐
//   │ Disclaimer banner                            │
//   ├─────────────────────────────────────────────┤
//   │ [Parser▼] [Search box____________] [Search]  │
//   ├──────────────────────┬──────────────────────┤
//   │                      │                      │
//   │   Search results     │   Chapter list       │
//   │   (grid of cards      │   (list of tiles     │
//   │    with cover art)    │    with download     │
//   │                      │    buttons)           │
//   │                      │                      │
//   ├──────────────────────┴──────────────────────┤
//   │ Status bar: "Ready."                         │
//   └─────────────────────────────────────────────┘
//
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../parsers/registry.dart';
import 'app_state.dart';
import 'chapter_panel.dart';
import 'manga_card.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('mangodl-flutter'),
        actions: [
          // Show the disclaimer in a dialog when the user taps the help icon.
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDisclaimer(context),
            tooltip: 'About / Disclaimer',
          ),
        ],
      ),
      body: const Column(
        children: [
          _DisclaimerBanner(),
          _SearchBar(),
          Expanded(child: _TwoPanel()),
          _StatusBar(),
        ],
      ),
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Disclaimer'),
        content: const SingleChildScrollView(
          child: Text(
            'This project is strictly for educational purposes. It teaches '
            'HTTP scraping, HTML parsing, and modular parser design. '
            '\n\n'
            'All manga, characters, artwork, and trademarks belong to '
            'their rightful rights holders. Do NOT use this code to '
            'download content you do not have the legal right to access. '
            'Support official releases whenever possible.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.orange.shade50,
      child: const Text(
        'Strictly for educational purposes. All manga rights belong to '
        'their rightful holders. Do not download content you do not have '
        'the legal right to access.',
        style: TextStyle(fontSize: 12, color: Colors.brown),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MangodlAppState>();
    final parsers = ParserRegistry.all();
    final controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Parser selector.
          DropdownButton<String>(
            value: state.selectedParserKey,
            items: parsers
                .map((p) => DropdownMenuItem(
                      value: p['key'],
                      child: Text(p['displayName']!),
                    ))
                .toList(),
            onChanged: (k) {
              if (k != null) state.selectParser(k);
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Search for a manga title…',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (v) => state.search(v),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: state.phase == AppState.searching
                ? null
                : () => state.search(controller.text),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}

class _TwoPanel extends StatelessWidget {
  const _TwoPanel();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 800;
        if (wide) {
          // Two-column: results left, chapters right.
          return Row(
            children: [
              Expanded(flex: 3, child: _SearchResults()),
              const VerticalDivider(width: 1),
              Expanded(flex: 2, child: ChapterPanel()),
            ],
          );
        }
        // Narrow: stack results; chapters appear as a bottom sheet.
        return _SearchResults();
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<MangodlAppState>();

    if (state.phase == AppState.searching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.lastError != null && state.searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error: ${state.lastError}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    if (state.searchResults.isEmpty) {
      return const Center(child: Text('Search results will appear here.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: state.searchResults.length,
      itemBuilder: (context, i) => MangaCard(
        manga: state.searchResults[i],
        selected: state.selectedManga?.id == state.searchResults[i].id,
        onTap: () => state.selectManga(state.searchResults[i]),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MangodlAppState>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Text(
        state.statusMessage,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
      ),
    );
  }
}
