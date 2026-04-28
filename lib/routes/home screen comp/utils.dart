import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/services/bookToDb.dart';

Future<void> deleteBooks(List<int> deletedBookIds) async {
  if (deletedBookIds.isEmpty) return;

  for (final id in deletedBookIds) {
    await BookToDb().deleteBook(id);
  }
}

Future<void> addToCollection(String collectionName, int bookId) async {
  Collection? collection = await BookToDb().getCollection(collectionName);
  if (collection != null) {
    BookToDb().setBookCollection(bookId, collection.id);
  } else {
    int id = await BookToDb().addCollection(collectionName);
    BookToDb().setBookCollection(bookId, id);
  }
}
