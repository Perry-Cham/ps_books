// =============================================================================
// mangodl_flutter — Educational Flutter port of mangodl-nodejs.
// See lib/parsers/base.dart for the project-wide disclaimer.
// =============================================================================

// -----------------------------------------------------------------------------
// lib/ui/manga_card.dart — A single search-result card.
//
// Shows cover art + title. Clicking it tells the app state to load
// chapters for this manga. Mirrors the .manga-card div in the JS
// version's index.html.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../parsers/base.dart';

class MangaCard extends StatelessWidget {
  final MangaSearchResult manga;
  final bool selected;
  final VoidCallback onTap;

  const MangaCard({
    super.key,
    required this.manga,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: selected
          ? RoundedRectangleBorder(
              side: const BorderSide(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover image. If the URL is empty or fails to load, fall
            // back to a placeholder.
            Expanded(
              child: manga.coverUrl.isEmpty
                  ? Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 48),
                    )
                  : Image.network(
                      manga.coverUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.cumulativeBytesLoaded /
                                (progress.expectedTotalBytes ?? 1),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 48),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                manga.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
