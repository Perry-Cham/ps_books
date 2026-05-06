import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';
import 'package:ps_books/routes/bookshelf%20comp/uploaded_books.dart';
import 'package:ps_books/routes/bookshelf%20comp/wishlist.dart';
import 'package:ps_books/state/library_state.dart';

final _db = DBProvider().db;

class Bookshelf extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookshelf'),
        backgroundColor: Colors.cyan,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Page(),
    );
  }
}

class Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [Expanded(child: _TabbedPage())]);
  }
}

class _TabbedPage extends StatefulWidget {
  const _TabbedPage({super.key});

  @override
  State<_TabbedPage> createState() => _TabbedPageState();
}

class _TabbedPageState extends State<_TabbedPage>
    with TickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _controller,
          tabs: [
            Tab(text: "Wishlist"),
            Tab(text: "Bookshelf"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: [DrivePage(), WishlistPage()],
          ),
        ),
      ],
    );
  }
}

