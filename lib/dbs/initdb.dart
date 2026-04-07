
import 'package:ps_books/dbs/database.dart';

class DBProvider {
  static final DBProvider _instance = DBProvider._internal();
  late final AppDatabase db;

  factory DBProvider() {
    return _instance;
  }

  DBProvider._internal() {
    db = AppDatabase();
  }
}