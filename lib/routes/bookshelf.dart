import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/routes/bookshelf%20comp/uploaded_books.dart';
import 'package:ps_books/routes/bookshelf%20comp/wishlist.dart';


class Bookshelf extends ConsumerWidget {
  const Bookshelf({super.key});


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
  const Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Expanded(child: _TabbedPage())]);
  }
}

class _TabbedPage extends StatefulWidget {
  const _TabbedPage();

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
            children: [WishlistPage(), DrivePage()],
          ),
        ),
      ],
    );
  }
}

