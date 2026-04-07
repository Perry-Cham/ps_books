import 'package:flutter/material.dart';
import './layout.dart';
import 'package:go_router/go_router.dart';
import 'package:katbook_epub_reader/katbook_epub_reader.dart';


//Routes
import 'home.dart';
import 'routes/study.dart';

void main() {
  runApp(MyApp());
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
          GoRoute(
            path: '/',
            builder: (context, state) => HomePage(title: "P's Books"),
          ),
          GoRoute(
            path: '/goals',
            builder: (context, state) => StudyPage(),
          ),
          GoRoute(
            path: '/study',
            builder: (context, state) => const Text('study page'),
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
