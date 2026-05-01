import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/downloader.dart';
import '../state/download_state.dart';

class DownloadSearch extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download Page'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return DownloadsDisplay();
                },
              );
            },
            icon: Icon(Icons.download_sharp),
          ),
        ],
      ),
      body: Page(),
    );
  }
}

class Page extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(DownloadStateProvider);
    return Column(
      children: [
        SearchBar(),
        if (downloadState.searchResults != null &&
            downloadState.searchResults!.isNotEmpty)
          Expanded(child: BookGrid(books: downloadState.searchResults!))
        else
          Expanded(
            child: Center(child: Text('Your search results will appear')),
          ),
      ],
    );
  }
}

class SearchBar extends ConsumerStatefulWidget {
  const SearchBar({super.key});

  @override
  ConsumerState<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
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
        Expanded(child: TextFormField(controller: _searchController)),
        FilledButton.icon(
          onPressed: () async {
            List<DownloadBook> books = await SearchBooks(
              _searchController.text,
            );
            print("The book objects are here");
            print(books);

            print("State update section is here");
            ref.read(DownloadStateProvider.notifier).updateState(books);
          },
          label: Text("Search"),
          icon: Icon(Icons.search_sharp),
        ),
      ],
    );
  }
}

class BookGrid extends ConsumerWidget {
  final List<DownloadBook> books;

  const BookGrid({super.key, required this.books});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        childAspectRatio: 0.7,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text(book.title, textAlign: TextAlign.center),
                  ),
                ),
                Text('Year: ${book.year}'),
                Text('Extension: ${book.extension}'),
                Text('Extension: ${book.size}'),
                ElevatedButton(
                  onPressed: () async {
                    String? link = await downloadPageScraper(book.href);
                    if (link != null) {
                      // Get filename first
                      try {
                        String fileName = await getFileName(link);
                        // Set the file name in the provider
                        ref
                            .read(downloadProgressProvider.notifier)
                            .setFileName(fileName);

                        // Listen to download progress stream
                        downloadBookWithProgress(link).listen(
                          (progress) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download has started")));
                            // Update progress in the provider
                            ref
                                .read(downloadProgressProvider.notifier)
                                .updateProgress(progress);
                          },
                          onDone: () {
                            // Reset when download is complete
                            Future.delayed(Duration(seconds: 2), () {
                              ref
                                  .read(downloadProgressProvider.notifier)
                                  .resetProgress();
                            });
                          },
                          onError: (error) {
                            print('Download error: $error');
                            ref
                                .read(downloadProgressProvider.notifier)
                                .resetProgress();
                          },
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Downloading $fileName')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Download failed: $e')),
                        );
                      }
                    }
                  },
                  child: Text('Download'),
                ),
              ],
            ),
          ),
        );
      },
    );
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadProgress = ref.watch(downloadProgressProvider);
    if(downloadProgress.progress == 1) Navigator.pop(context);
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    downloadProgress.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: downloadProgress.progress,
                      minHeight: 4,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${(downloadProgress.progress * 100).toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
