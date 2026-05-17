import 'package:flutter/material.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/readers/reader.dart';
import 'package:ps_books/services/DB%20services/bookToDb.dart';

final _db = BookToDb();

class CurrentlyReading extends StatelessWidget {
  const CurrentlyReading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Book?>(
      stream: _db.getCurrentlyReading(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final book = snapshot.data;
        if (book != null) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/no-book.jpg',
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.name),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: book.progress),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
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
                        label: const Text('Resume'),
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