import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/readers/reader.dart';
import 'package:ps_books/services/DB%20services/bookToDb.dart';
import 'package:ps_books/state/reader_state.dart';

final _db = BookToDb();

class CurrentlyReading extends ConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<Book?>(
      stream: _db.getCurrentlyReading(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(height: 120, child: SizedBox.shrink());
        }
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }

        final book = snapshot.data;
        if (book != null) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: 90,
                      height: 120,
                      child: (book.coverPath != null)
                          ? Image.file(
                            File(book.coverPath!),
                            fit: BoxFit.cover,
                          )
                          : Image.asset(
                            'assets/no_book.jpg',
                            fit: BoxFit.cover,
                          ),
                    ),
                  ],
                ),

                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (book.name != "") ? book.name : "Unknown",
                        maxLines: 2,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (book.author != null)
                        Text(
                          book.author!,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: book.progress),
                      const SizedBox(height: 8),
                      IconButton.filled(
                        onPressed: () {
                          ref.read(readerStateProvider.notifier).setIsReadingTrue();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Reader(
                                path: book.path,
                                type: book.extension,
                                id: book.id,
                                page: book.page,
                                position: book.cfi,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16.0),
          child: const Center(
            child: Text("You haven't started reading anything yet"),
          ),
        );
      },
    );
  }
}
