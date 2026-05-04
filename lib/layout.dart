import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

//This ile determines the layout for the whole page it defines naviagtion rails and an expanded component where the rest of the widget lives

class Layout extends StatefulWidget {
  const Layout({super.key, required this.widget});
  final Widget widget;

  @override
  State<Layout> createState() => LayoutState();
}

class LayoutState extends State<Layout> {
  bool extended = false;
  static const destinations = [
    '/',
    '/bookshelf',
    '/goals',
    '/download',
    '/settings',
  ];

  @override
  Widget build(BuildContext context) {
    final locationUrl = GoRouterState.of(context).uri.toString();
    final index = destinations.indexOf(locationUrl);
    if (!Platform.isAndroid) {
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
                    ? Row(
                        spacing: 20,
                        children: [Icon(Icons.book), Text("P's Books")],
                      )
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
                  icon: Icon(Icons.bookmark_add_outlined),
                  selectedIcon: Icon(Icons.bookmark_add),
                  label: Text('Bookshelf'),
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
                NavigationRailDestination(
                  icon: Icon(Icons.settings_applications),
                  selectedIcon: Icon(Icons.settings_applications),
                  label: Text('Settings'),
                ),
              ],
            ),
            Expanded(child: widget.widget),
          ],
        ),
      );
    } else {
      final locationUrl = GoRouterState.of(context).uri.toString();
      final index = destinations.indexOf(locationUrl);
      return Scaffold(
        body: widget.widget,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.blueGrey, // Matches your NavigationRail
          selectedItemColor: Colors.white, // Color of the active icon/label
          unselectedItemColor: Colors.white70,
          currentIndex: index,
          onTap: (value) {
            context.go(destinations[value]);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_add_outlined),
              label: 'Bookshelf',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flag_outlined),
              label: 'Study',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_applications_outlined),
              label: 'Settings',
            ),
          ],
        ),
      );
    }
  }
}
