import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//This ile determines the layout for the whole page it defines naviagtion rails and an expanded component where the rest of the widget lives

class Layout extends StatefulWidget {
  const Layout({super.key, required this.widget});
  final Widget widget;

  @override
  State<Layout> createState() => LayoutState();
}

class LayoutState extends State<Layout> {
  bool extended = false;
  static const destinations = ['/', '/goals', '/download'];

  @override
  Widget build(BuildContext context) {
    final locationUrl = GoRouterState.of(context).uri.toString();
    final index = destinations.indexOf(locationUrl);
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            selectedIndex: index,
            onDestinationSelected: (index) {
              context.go(destinations[index]);
            },
            leading: InkWell(
              onTap: () {
                setState(() {
                  extended = !extended;
                });
              },
              child: extended
                  ? Row(spacing:20, children: [Icon(Icons.book), Text("P's Books")])
                  : Icon(Icons.book),
            ),
            backgroundColor: Colors.blueGrey,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.library_books_outlined),
                selectedIcon: Icon(Icons.library_books),
                label: Text('Library'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.flag_outlined),
                selectedIcon: Icon(Icons.flag),
                label: Text('Study'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: Text('Goals'),
              ),
            ],
          ),
          Expanded(child: widget.widget),
        ],
      ),
    );
  }
}
