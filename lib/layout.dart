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
  static const destinations = ['/', '/goals', '/study'];

  @override
  Widget build(BuildContext context) {
    final locationUrl = GoRouterState.of(context).uri.toString();
    final index = destinations.indexOf(locationUrl);
    return Scaffold(
      body: Row(
        children: [
          MouseRegion(
            onEnter: (_) => setState(() => extended = true),
            onExit: (_) => setState(() => extended = false),
            child: NavigationRail(
              extended: extended,
              selectedIndex: index,
              onDestinationSelected: (index) {
                context.go(destinations[index]);
              },
              leading:AnimatedSwitcher(duration: Duration(milliseconds: 500), 
              child:extended ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, spacing:5, children:[Icon(Icons.menu_book), Text("P's Books", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)]) : Icon(Icons.menu_book)) ,
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
                  label: Text('Goals'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book),
                  label: Text('Study'),
                ),
              ],
            ),
          ),
          Expanded(child: widget.widget),
        ],
      ),
    );
  }
}
