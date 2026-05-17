import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/routes/bookshelf%20comp/uploaded_books.dart';
import 'package:ps_books/routes/bookshelf%20comp/wishlist.dart';
import 'package:ps_books/state/wishlist.dart';
import 'package:ps_books/routes/home%20comp/control_bars.dart';


class Bookshelf extends ConsumerWidget {
  const Bookshelf({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistSelectionCount = ref.watch(
      WishlistStateProvider.select((state) => state.selectedBookIds.length),
    );
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    String title = "Bookshelves";
    if (isAndroid && wishlistSelectionCount > 0) {
      title = "$wishlistSelectionCount selected";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF1E1729),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopUpControls(provider: WishlistStateProvider, wishlist: true),
        ],
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
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF1B1227),
            ),
            child: TabBarView(
              controller: _controller,
              children: [WishlistPage(), DrivePage()],
            ),
          )
        ),
      ],
    );
  }
}

