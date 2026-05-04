import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/routes/settings.dart';
import 'package:ps_books/routes/wishlist.dart';
import 'package:ps_books/services/reader-preferences.dart';
import 'package:ps_books/state/prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './layout.dart';
import 'package:go_router/go_router.dart';
import 'package:katbook_epub_reader/katbook_epub_reader.dart';

import 'routes/home.dart';
import 'routes/study.dart';
import 'package:ps_books/routes/download.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  //routes
  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Layout(widget: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => HomePage()),
          GoRoute(path: '/bookshelf', builder: (context, state) => Wishlist()),
          GoRoute(path: '/goals', builder: (context, state) => StudyPage()),
          GoRoute(
            path: '/download',
            builder: (context, state) => DownloadSearch(),
          ),
          GoRoute(path: '/settings', builder: (context, state) => Settings()),
        ],
      ),
    ],
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "P's Books",
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      routerConfig: _router,
    );
  }
}
