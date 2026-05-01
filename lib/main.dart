import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/services/downloader.dart';
import './layout.dart';
import 'package:go_router/go_router.dart';
import 'package:katbook_epub_reader/katbook_epub_reader.dart';

import 'routes/home.dart';
import 'routes/study.dart';
import 'package:ps_books/routes/download.dart';
import 'package:ps_books/routes/actual_download.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
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
          GoRoute(path: '/goals', builder: (context, state) => StudyPage()),
          GoRoute(
            path: '/download',
            builder: (context, state) => DownloadSearch(),
          ),
          GoRoute(
            path: '/actual_download',
            builder: (context, state) => ActualDownloadPage(book: state.extra as DownloadBook),
          ),
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
