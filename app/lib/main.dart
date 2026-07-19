import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart' as pdf;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:katbook_epub_reader/katbook_epub_reader.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io';

import 'package:ps_books/services/notifications.dart';
import 'package:ps_books/services/study/target_sync.dart' as target_sync;
import 'routes/home.dart';
import 'routes/study.dart';
import 'package:ps_books/routes/download.dart';
import 'package:ps_books/routes/settings.dart' as settings_route;
import 'package:ps_books/routes/bookshelf.dart';
import 'package:ps_books/routes/login.dart';
import './layout.dart';

import 'package:ps_books/state/global_settings.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await pdf.pdfrxFlutterInitialize();
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer();
  globalProviderContainer = container;

  if (Platform.isAndroid) {
    await Workmanager().initialize(registerStudyNotifications);
    final bool enableAlarms = prefs.getBool('enableAlarms') ?? false;
    if (enableAlarms) {
      await Workmanager().registerPeriodicTask(
        "timetable-sync-task", // Unique name
        "sync-timetable", // Internal task key
        frequency: const Duration(hours: 24), // Run once a day
        constraints: Constraints(
          networkType: NetworkType.notRequired, // Run even offline
          requiresBatteryNotLow: false,
        ),
      );
    } else {
      await Workmanager().cancelByUniqueName("timetable-sync-task");
    }
  }

  if (prefs.getBool('ps_signed_in') ?? false) {
    target_sync.syncTargetsIfSignedIn();
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => Layout(widget: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => HomePage()),
          GoRoute(path: '/bookshelf', builder: (context, state) => Bookshelf()),
          GoRoute(path: '/goals', builder: (context, state) => StudyPage()),
          GoRoute(
            path: '/download',
            builder: (context, state) {
              final query = state.uri.queryParameters['search'];
              return DownloadSearch(query: query);
            },
          ),
          GoRoute(path: '/settings', builder: (context, state) => settings_route.Settings()),
          GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: "P's Books",
      themeMode: settingsAsync.when(
        data: (settings) => settings.appTheme == AppTheme.dark ? ThemeMode.dark : ThemeMode.light,
        loading: () => ThemeMode.dark,
        error: (_, _) => ThemeMode.dark,
      ),
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      routerConfig: router,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final typographyColor = Typography();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // ==================== CORE COLORS ====================
      scaffoldBackgroundColor: isDark ? const Color(0xFF1B1227) : const Color(0xFFF8F7FA),

      // ==================== APPBAR ====================
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1E1729) : const Color(0xFFFFFFFF),
        foregroundColor: isDark ? const Color(0xFFE2E0E5) : const Color(0xFF1B1227),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.025,
          color: isDark ? const Color(0xFFE2E0E5) : const Color(0xFF1B1227),
        ),
        iconTheme: IconThemeData(color: isDark ? const Color(0xFFE2E0E5) : const Color(0xFF1B1227)),
        actionsIconTheme: IconThemeData(color: isDark ? const Color(0xFFE2E0E5) : const Color(0xFF1B1227)),
      ),

      // ==================== OTHER COMPONENTS ====================
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E1729) : const Color(0xFFFFFFFF),
        elevation: isDark ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color.fromRGBO(255, 255, 255, 0.04) : const Color.fromRGBO(0, 0, 0, 0.04),
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF7C3AED),
        foregroundColor: Colors.white,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          foregroundColor: isDark ? Colors.white : Colors.black87,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF110D17).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: isDark ? const Color(0xFF737373) : const Color(0xFF94A3B8),
        elevation: 0,
      ),

      dividerTheme: DividerThemeData(
        color: isDark ? const Color.fromRGBO(255, 255, 255, 0.04) : const Color.fromRGBO(0, 0, 0, 0.04),
        thickness: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color.fromRGBO(255, 255, 255, 0.06) : const Color.fromRGBO(0, 0, 0, 0.06),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color.fromRGBO(255, 255, 255, 0.06) : const Color.fromRGBO(0, 0, 0, 0.06),
          ),
        ),
      ),
      /*popupMenuTheme: PopupMenuThemeData(
        color: isDark ? const Color(0xFF1B1227) : const Color(0x7A7A7AFF),
      ),*/
      chipTheme: ChipThemeData.fromDefaults(primaryColor: isDark ? Colors.grey : Colors.white, secondaryColor:  Colors.deepPurple, labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black)),
   textTheme: !isDark ? typographyColor.black : typographyColor.white,
    );

  }
}
