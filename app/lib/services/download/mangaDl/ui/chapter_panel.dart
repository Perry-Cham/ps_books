// =============================================================================
// mangodl_flutter — Educational Flutter port of mangodl-nodejs.
// See lib/parsers/base.dart for the project-wide disclaimer.
// =============================================================================

// -----------------------------------------------------------------------------
// lib/ui/chapter_panel.dart — The chapter list panel.
//
// Mirrors the #chapter-panel aside in the JS version's index.html.
// Shows the selected manga's title at the top and a scrollable list
// of chapters below. Each chapter is a ListTile with a download
// button on the right.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

class ChapterPanel extends StatelessWidget {
  const ChapterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MangodlAppState>();

    if (state.selectedManga == null) {
      return const Center(
        child: Text(
          'Select a manga to see its chapters.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Text(
            state.selectedManga!.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        if (state.phase == AppState.loadingChapters)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state.chapters.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No chapters found.')),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: state.chapters.length,
              itemBuilder: (context, i) {
                final ch = state.chapters[i];
                final status = state.statusOf(ch.id);
                return ListTile(
                  title: Text(ch.label),
                  subtitle: ch.publishedAt != null
                      ? Text(
                          DateTime.tryParse(ch.publishedAt!) != null
                              ? DateTime.parse(ch.publishedAt!).toLocal().toString().substring(0, 16)
                              : ch.publishedAt!,
                          style: const TextStyle(fontSize: 11),
                        )
                      : null,
                  trailing: _trailingForStatus(status, ch.id, state),
                  onTap: status?.status == 'downloading'
                      ? null
                      : () => state.downloadChapter(ch),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _trailingForStatus(ChapterDownloadStatus? status, String id, MangodlAppState state) {
    if (status == null) {
      return const Icon(Icons.download, color: Colors.blue);
    }
    switch (status.status) {
      case 'downloading':
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case 'done':
        return const Icon(Icons.check, color: Colors.green);
      case 'error':
        return const Icon(Icons.error, color: Colors.red);
      default:
        return const Icon(Icons.download, color: Colors.blue);
    }
  }
}
