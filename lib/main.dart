import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' as debug;
import 'package:pdfrx/pdfrx.dart' as pdf;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:katbook_epub_reader/katbook_epub_reader.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io';

import 'package:ps_books/services/notifications.dart';
import 'routes/home.dart';
import 'routes/study.dart';
import 'package:ps_books/routes/download.dart';
import 'package:ps_books/routes/settings.dart';
import 'package:ps_books/routes/bookshelf.dart';
import 'package:ps_books/state/prefs.dart';
import './layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await pdf.pdfrxFlutterInitialize();
  final prefs = await SharedPreferences.getInstance();
 // debug.debugPaintSizeEnabled = true;

  if (Platform.isAndroid) {
    await Workmanager().initialize(registerStudyNotifications);
    await Workmanager().registerPeriodicTask(
      "timetable-sync-task", // Unique name
      "sync-timetable", // Internal task key
      frequency: const Duration(hours: 24), // Run once a day
      constraints: Constraints(
        networkType: NetworkType.notRequired, // Run even offline
        requiresBatteryNotLow: false,
      ),
    );
  }

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
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
          GoRoute(path: '/bookshelf', builder: (context, state) => Bookshelf()),
          GoRoute(path: '/goals', builder: (context, state) => StudyPage()),
          GoRoute(
            path: '/download',
            builder: (context, state){
              final query = state.uri.queryParameters['search'];
              return DownloadSearch(query: query);},
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
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        // ==================== CORE COLORS ====================
        scaffoldBackgroundColor: const Color(0xFF1B1227), // Base Canvas


        // ==================== TEXT THEME (Default White-ish) ====================


        // ==================== APPBAR ====================
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1729),        // Surface 100
          foregroundColor: Color(0xFFE2E0E5),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.025,
            color: Color(0xFFE2E0E5),
          ),
          iconTheme: IconThemeData(color: Color(0xFFE2E0E5)),
          actionsIconTheme: IconThemeData(color: Color(0xFFE2E0E5)),
        ),

        // ==================== OTHER COMPONENTS ====================
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1729), // Surface 100
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color.fromRGBO(255, 255, 255, 0.04)),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF7C3AED),
          foregroundColor: Colors.white,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF110D17).withOpacity(0.9),
          selectedItemColor: const Color(0xFFA78BFA),
          unselectedItemColor: const Color(0xFF737373),
          elevation: 0,
        ),

        dividerTheme: const DividerThemeData(
          color: Color.fromRGBO(255, 255, 255, 0.04),
          thickness: 1,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
         fillColor: Colors.grey.shade600, // Surface 200
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color.fromRGBO(255, 255, 255, 0.06)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color.fromRGBO(255, 255, 255, 0.06)),
          ),
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      routerConfig: _router,
    );
  }
}
