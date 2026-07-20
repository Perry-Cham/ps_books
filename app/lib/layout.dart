import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import 'package:ps_books/state/reader_state.dart';

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
    final locationUrl = GoRouterState.of(context).uri.path;
    final index = destinations.indexOf(locationUrl);
    final theme = Theme.of(context);

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
                    ? const Row(
                        spacing: 20,
                        children: [Icon(Icons.book), Text("P's Books")],
                      )
                    : const Icon(Icons.book),
              ),
              backgroundColor: theme.appBarTheme.backgroundColor,
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
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
            Expanded(child: widget.widget),
          ],
        ),
      );
    } else {

      return Scaffold(
        body: widget.widget,
        bottomNavigationBar: CustomBottomNav(destinations: destinations)
      );
    }
  }
}


class CustomBottomNav extends ConsumerWidget{
  final List<String> destinations;

  const CustomBottomNav({super.key, required this.destinations});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReading =
        ref.watch(readerStateProvider.select((state) => state.isReading));

    final locationUrl = GoRouterState.of(context).uri.path;
    final index = destinations.indexOf(locationUrl);
    final theme = Theme.of(context);

    if (isReading) {
      return const SizedBox.shrink();
    }
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) {
        context.go(destinations[value]);
      },
      backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
      indicatorColor: theme.bottomNavigationBarTheme.selectedItemColor?.withValues(alpha: 0.2),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.library_books_outlined),
          selectedIcon: Icon(Icons.library_books_rounded),
          label: 'Library',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_add_outlined),
          selectedIcon: Icon(Icons.bookmark_add),
          label: 'Bookshelf',
        ),
        NavigationDestination(
          icon: Icon(Icons.flag_outlined),
          selectedIcon: Icon(Icons.flag),
          label: 'Study',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search),
          label: 'Find',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
