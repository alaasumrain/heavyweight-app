// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'backend/supabase/supabase_workout_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'backend/supabase/supabase.dart';
import 'providers/profile_provider.dart';
import 'providers/repository_provider.dart';
import 'providers/mandate_engine_provider.dart';
import 'providers/app_state_provider.dart';
import 'nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Initialize providers
  final repositoryProvider = RepositoryProvider();
  await repositoryProvider.initialize();
  
  final appStateProvider = AppStateProvider();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ChangeNotifierProvider(create: (context) => MandateEngineProvider()),
      ChangeNotifierProvider.value(value: repositoryProvider),
      ChangeNotifierProvider.value(value: appStateProvider),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App resumed - process offline queue
      _processOfflineQueueIfNeeded();
    }
  }
  
  void _processOfflineQueueIfNeeded() {
    try {
      final repositoryProvider = context.read<RepositoryProvider>();
      final repository = repositoryProvider.repository;
      if (repository is SupabaseWorkoutRepository) {
        repository.processOfflineQueue().catchError((error) {
          print('Failed to process offline queue on app resume: $error');
        });
      }
    } catch (e) {
      print('Error accessing repository for offline queue processing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HEAVYWEIGHT',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFF111111),
        primaryColor: Colors.white,
        textTheme: GoogleFonts.ibmPlexMonoTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xFF444444),
          surface: Color(0xFF111111),
          background: Color(0xFF111111),
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
            textStyle: GoogleFonts.ibmPlexMono(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            side: const BorderSide(color: Colors.white),
          ),
        ),
        cardTheme: const CardTheme(
          color: Color(0xFF111111),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF111111),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.ibmPlexMono(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF111111),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Color(0xFF444444)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.white),
          ),
          labelStyle: GoogleFonts.ibmPlexMono(color: const Color(0xFF444444)),
          hintStyle: GoogleFonts.ibmPlexMono(color: const Color(0xFF444444)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFF111111),
        primaryColor: Colors.white,
        textTheme: GoogleFonts.ibmPlexMonoTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xFF444444),
          surface: Color(0xFF111111),
          background: Color(0xFF111111),
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
            textStyle: GoogleFonts.ibmPlexMono(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            side: const BorderSide(color: Colors.white),
          ),
        ),
        cardTheme: const CardTheme(
          color: Color(0xFF111111),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF111111),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.ibmPlexMono(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF111111),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Color(0xFF444444)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.white),
          ),
          labelStyle: GoogleFonts.ibmPlexMono(color: const Color(0xFF444444)),
          hintStyle: GoogleFonts.ibmPlexMono(color: const Color(0xFF444444)),
        ),
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
