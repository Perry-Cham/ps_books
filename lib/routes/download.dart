import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/downloader.dart';
import '../state/download_state.dart';

class DownloadSearch extends ConsumerStatefulWidget {
  const DownloadSearch({super.key, this.query});
  final String? query;
  @override
  ConsumerState<DownloadSearch> createState() {
    return DownloadSearchState();
  }
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
        title: Text('Discover'),
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
  const Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(DownloadStateProvider);
    return Column(
      children: [

        Center(child: SizedBox(width: 400, height: 100, child: SearchBar())),
        if (downloadState.loading != null && downloadState.loading!)
    Expanded(
    child: LoadingResults()
    )
        else if (downloadState.searchResults != null &&
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
        Expanded(
          child: TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () async {
                 try{
                   await _searchBooks(ref, _searchController.text);
                 }catch(e){
                   print(e);
                   ref.read(DownloadStateProvider.notifier).updateState(loading: false);
                 }
                },
                icon: Icon(Icons.search),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              label: Text("Search"),
            ),
          ),
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
        crossAxisSpacing: 10,
        childAspectRatio: 200 / 300,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Stack(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    if(book.isbn != null)Image.network('https://covers.openlibrary.org/b/isbn/${book.isbn![0]}-M.jpg'),
                    Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(book.title, textAlign: TextAlign.center),
                          ),
                        ),
                        Text('Year: ${book.year}'),
                        Text('Extension: ${book.extension}'),
                        Text('Language: ${book.language}'),
                        Text('Size: ${book.size}'),
                      ],
                    ),
                  ],
                )
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton.filled(
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Download has started")),
                          );
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
                icon: Icon(Icons.file_download_outlined),
              ),
            ),
          ],
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
  const DownloadsDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadProgress = ref.watch(downloadProgressProvider);
    if (downloadProgress.progress == 1) Navigator.pop(context);
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

class LoadingResults extends StatelessWidget {
  const LoadingResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularProgressIndicator(),
        Text('Fetching The results For You'),
      ],
    );
  }
}

Future<void> _searchBooks(WidgetRef ref, String text) async {
  ref.read(DownloadStateProvider.notifier).updateState(loading: true);
  List<DownloadBook> books = await SearchBooks(text);
  print("The book objects are here");
  print(books);

  print("State update section is here");
  ref
      .read(DownloadStateProvider.notifier)
      .updateState(books: books, loading: false);
}
