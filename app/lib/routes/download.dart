import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ps_books/models/comic_book_model.dart';
import '../services/download/downloader.dart' hide DownloadProvider;
import '../state/download_state.dart';
import 'downloadComp/comics/series_download_view.dart';

class DownloadSearch extends ConsumerStatefulWidget {
  const DownloadSearch({super.key, this.query});

  final String? query;

  @override
  ConsumerState<DownloadSearch> createState() => DownloadSearchState();
}

class DownloadSearchState extends ConsumerState<DownloadSearch> {
  @override
  void initState() {
    super.initState();
    if (widget.query != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchBooks(ref, widget.query!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const DownloadsDisplay(),
              );
            },
            icon: const Icon(Icons.download_sharp),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: const _SearchSettingsDrawer(),
      body: const Page(),
    );
  }
}

class _SearchSettingsDrawer extends ConsumerWidget {
  const _SearchSettingsDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(DownloadStateProvider);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              'Search Settings',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            title: const Text('Search Type'),
            subtitle: Text(state.searchMode == SearchMode.series ? 'Series/OPDS' : 'Normal'),
          ),
          SwitchListTile(
            title: const Text('Series/OPDS Mode'),
            subtitle: const Text('Search for series, comics, and collections'),
            value: state.searchMode == SearchMode.series,
            onChanged: (val) {
              ref.read(DownloadStateProvider.notifier).updateState(
                searchMode: val ? SearchMode.series : SearchMode.normal,
              );
            },
          ),
        ],
      ),
    );
  }
}

class Page extends ConsumerWidget {
  const Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(DownloadStateProvider);
    return Column(
      children: [
        Center(
          child: SizedBox(width: 400, height: 80, child: const DownloadSearchBar()),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: ProviderPills(),
        ),
        if (downloadState.loading == true)
          const Expanded(child: LoadingResults())
        else if (downloadState.searchResults != null &&
            downloadState.searchResults!.isNotEmpty)
          Expanded(child: BookGrid(books: downloadState.searchResults!))
        else
          const Expanded(
            child: Center(child: Text('Your search results will appear')),
          ),
      ],
    );
  }
}

class ProviderPills extends ConsumerWidget {
  const ProviderPills({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProvider = ref.watch(DownloadStateProvider).downloadProvider;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPill(ref, 'Libgen', DownloadProvider.libgen, selectedProvider),
        const SizedBox(width: 10),
        _buildPill(ref, 'Standard Ebooks', DownloadProvider.steb, selectedProvider),
        const SizedBox(width: 10),
        _buildPill(ref, 'Manga', DownloadProvider.manga, selectedProvider),
      ],
    );
  }

  Widget _buildPill(
    WidgetRef ref,
    String label,
    DownloadProvider provider,
    DownloadProvider selected,
  ) {
    final isSelected = provider == selected;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          ref
              .read(DownloadStateProvider.notifier)
              .updateState(downloadProvider: provider);
        }
      },
    );
  }
}

class DownloadSearchBar extends ConsumerStatefulWidget {
  const DownloadSearchBar({super.key});

  @override
  ConsumerState<DownloadSearchBar> createState() => _DownloadSearchBarState();
}

class _DownloadSearchBarState extends ConsumerState<DownloadSearchBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _searchController,
            onFieldSubmitted: (_) {
              _searchBooks(ref, _searchController.text);
            },
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () async {
                  try {
                    await _searchBooks(ref, _searchController.text);
                  } catch (e, h) {
                    print(e);
                    print(h);
                    ref
                        .read(DownloadStateProvider.notifier)
                        .updateState(loading: false);
                  }
                },
                icon: const Icon(Icons.search),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              label: const Text("Search"),
            ),
          ),
        ),
      ],
    );
  }
}

class BookGrid extends ConsumerWidget {
  final List<SeriesModel> books;

  const BookGrid({super.key, required this.books});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(downloadProgressProvider, (next, prev) {
      if (next != null && next.completedMessage != "") {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.completedMessage)));
      }
    });
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        mainAxisSpacing: 10,
        childAspectRatio: 200 / 300,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];

        final String? coverUrl = (book.isbn != null && book.isbn!.isNotEmpty)
            ? 'https://covers.openlibrary.org/b/isbn/${book.isbn![0]}-L.jpg?default=false'
            : book.coverUrl;

        return SizedBox.expand(
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: coverUrl != null
                      ? Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const _CardFallbackBackground(),
                        )
                      : const _CardFallbackBackground(),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.5),
                          Colors.black.withValues(alpha: 0.95),
                        ],
                        stops: const [0.0, 0.4, 0.85],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Text(
                          book.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildMiniBadge(
                              book.extension.toUpperCase(),
                              Colors.deepPurple.shade700,
                            ),
                            if (book.year != null && book.year!.trim().isNotEmpty)
                              _buildMiniBadge(book.year!, Colors.grey.shade800),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Language: ${book.language} • Size: ${book.size}',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final searchMode = ref.read(DownloadStateProvider).searchMode;
                      if (searchMode == SearchMode.series) {
                        _openSeriesDownload(context, ref, book);
                      } else {
                        _startDirectDownload(context, ref, book);
                      }
                    },
                    icon: Icon(
                      ref.watch(DownloadStateProvider).searchMode == SearchMode.series
                          ? Icons.collections_bookmark
                          : Icons.file_download_outlined,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSeriesDownload(BuildContext context, WidgetRef ref, SeriesModel book) async {
    final provider = ref.read(DownloadStateProvider).downloadProvider;
    final providerStr = provider.name;
    final volumes = await GetVolumes(providerStr, book.detailUrl, series: true);
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SeriesDownloadView(seriesModel: book, volumes: volumes),
        ),
      );
    }
  }

  void _startDirectDownload(BuildContext context, WidgetRef ref, SeriesModel book) async {
    try {
      String fileName = await getFileName(book.detailUrl);
      ref
          .read(downloadProgressProvider.notifier)
          .setFileName(fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download has started")),
      );
      ref
          .read(downloadProgressProvider.notifier)
          .startDownload(book.detailUrl, fileName);
    } catch (e, h) {
      print(e);
      print(h);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  int _getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) return 5;
    if (width > 800) return 4;
    if (width > 600) return 3;
    if (width > 400) return 2;
    return 2;
  }
}

class DownloadsDisplay extends ConsumerWidget {
  const DownloadsDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadProgress = ref.watch(downloadProgressProvider);
    if (downloadProgress.progress == 1) Navigator.pop(context);
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (downloadProgress.isDownloading)
              SizedBox(
                width: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      downloadProgress.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: downloadProgress.progress,
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(downloadProgress.progress * 100).toStringAsFixed(1)}%',
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(downloadProgressProvider.notifier).cancel();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "The download has been cancelled successfully",
                            ),
                          ),
                        );
                      },
                      label: Text("Cancel"),
                      icon: Icon(Icons.cancel_outlined),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 300,
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.equalizer_outlined),
                    Text("No Downloads Yet"),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LoadingResults extends StatelessWidget {
  const LoadingResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text('Fetching The results For You'),
      ],
    );
  }
}

Future<void> _searchBooks(WidgetRef ref, String text) async {
  final state = ref.read(DownloadStateProvider);
  final provider = state.downloadProvider;
  final isSeries = state.searchMode == SearchMode.series;
  final providerMap = {
    DownloadProvider.libgen: 'libgen',
    DownloadProvider.steb: 'steb',
    DownloadProvider.manga: 'manga',
  };
  ref.read(DownloadStateProvider.notifier).updateState(loading: true);

  List<SeriesModel> books;
  books = await SearchBooks(text, providerMap[provider]!, series: isSeries);

  ref
      .read(DownloadStateProvider.notifier)
      .updateState(books: books, loading: false);
}

class _CardFallbackBackground extends StatelessWidget {
  const _CardFallbackBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blueGrey.shade900, Colors.grey.shade900],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.book_outlined,
          size: 48,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}

Widget _buildMiniBadge(String label, Color backgroundColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
