// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages

import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'backend/supabase/supabase_workout_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'backend/supabase/supabase.dart';
import 'providers/profile_provider.dart';
import 'providers/repository_provider.dart';
import 'providers/workout_engine_provider.dart';
import 'providers/app_state_provider.dart';
import 'viewmodels/exercise_viewmodel.dart';
import 'core/auth_service.dart';
import 'core/error_handler.dart';
import 'nav.dart';
import 'core/logging.dart';
import 'core/router_refresh.dart';
import 'core/nav_logging.dart';

// Diagnostic flag: run with --dart-define=HW_DIAG=1 to boot a minimal app
const String _hwDiag = String.fromEnvironment('HW_DIAG', defaultValue: '');
const String _hwSimple = String.fromEnvironment('HW_SIMPLE', defaultValue: '');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  // Avoid runtime font fetching on iOS which can cause startup stalls
  // if App Transport Security blocks external hosts.
  // GoogleFonts runtime fetching disabled during iOS diagnosis (using bundled fonts instead)

  // If diagnostic mode is enabled, boot minimal app to validate rendering
  if (_hwDiag == '1' || _hwDiag.toLowerCase() == 'true') {
    debugPrint('🧪 HW DIAG MODE: Booting minimal app');
    runApp(const _HwDiagApp());
    return;
  }

  if (_hwSimple == '1' || _hwSimple.toLowerCase() == 'true') {
    debugPrint('🧪 HW SIMPLE MODE: Booting app shell without router');
    runApp(const _HwSimpleApp());
    return;
  }

  // Initialize global error handling
  HeavyweightErrorHandler.initialize();

  try {
    // Initialize Supabase using secure configuration (with timeout guard)
    final supabaseInitialized = await SupabaseService
        .initialize()
        .timeout(const Duration(seconds: 10), onTimeout: () => false);
    
    if (supabaseInitialized) {
      if (kDebugMode) {
        debugPrint('✅ HEAVYWEIGHT: Supabase initialized successfully');
      }
    } else {
      if (kDebugMode) {
        debugPrint('⚠️ HEAVYWEIGHT: Supabase not available - running in offline mode');
      }
      // Continue with app initialization - Supabase failure is not fatal
    }

    // Initialize auth service (with timeout guard)
    await AuthService().initialize().timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('Auth service initialization timed out'),
    );
    if (kDebugMode) {
      debugPrint('✅ HEAVYWEIGHT: Auth service initialized');
    }

    // Initialize providers
    final repositoryProvider = RepositoryProvider();
    await repositoryProvider
        .initialize()
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw TimeoutException('Repository provider initialization timed out');
    });
    if (kDebugMode) {
      debugPrint('✅ HEAVYWEIGHT: Repository provider initialized');
    }
    
    final appStateProvider = AppStateProvider();
    if (kDebugMode) {
      debugPrint('✅ HEAVYWEIGHT: App state provider initialized');
    }

    final exerciseViewModel = ExerciseViewModel();
    await exerciseViewModel.initialize();
    if (kDebugMode) {
      debugPrint('✅ HEAVYWEIGHT: Exercise view model initialized');
    }

    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ChangeNotifierProvider(create: (context) => WorkoutEngineProvider()),
        ChangeNotifierProvider.value(value: repositoryProvider),
        ChangeNotifierProvider.value(value: appStateProvider),
        ChangeNotifierProvider.value(value: AuthService()), // Add AuthService
        ChangeNotifierProvider.value(value: exerciseViewModel),
      ],
      child: const MyApp(),
    ));
    
    if (kDebugMode) {
      debugPrint('✅ HEAVYWEIGHT: App launched successfully');
    }
    
  } catch (error, stackTrace) {
    debugPrint('❌ HEAVYWEIGHT FATAL ERROR: $error');
    debugPrint('📍 Stack trace: $stackTrace');
    
    // Show error screen instead of black screen
    runApp(MaterialApp(
      title: 'HEAVYWEIGHT - Error',
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  'HEAVYWEIGHT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'INITIALIZATION FAILED',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ERROR DETAILS:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: const TextStyle(
                          color: Colors.red,
                          fontFamily: 'IBM Plex Mono',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Check the console logs for more details.\nThis usually indicates missing environment configuration.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

/// Minimal diagnostic app used to verify Flutter view renders on iOS
class _HwDiagApp extends StatefulWidget {
  const _HwDiagApp();

  @override
  State<_HwDiagApp> createState() => _HwDiagAppState();
}

class _HwDiagAppState extends State<_HwDiagApp> {
  int _ticks = 0;

  @override
  void initState() {
    super.initState();
    // Animate a counter to ensure frames are presented
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return false;
      setState(() => _ticks++);
      return _ticks < 40; // ~10 seconds
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF111111),
        body: Center(
          child: Text(
            'HW DIAG OK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple app to bypass GoRouter and theme; useful to validate rendering
class _HwSimpleApp extends StatelessWidget {
  const _HwSimpleApp();
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF111111),
        body: Center(
          child: Text(
            'HEAVYWEIGHT SIMPLE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  ThemeMode _themeMode = ThemeMode.dark;
  CombinedRefreshNotifier? _refreshNotifier;
  // We will always render MaterialApp.router; the builder shows a visible
  // fallback if the child is null to guarantee first paint.
  bool _booted = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _appStateNotifier = AppStateNotifier.instance;
    // Combine router refresh signals from both AppStateNotifier and AppStateProvider
    // so that changes in onboarding/auth immediately re-evaluate redirects.
    final appStateProvider = context.read<AppStateProvider>();
    _refreshNotifier = CombinedRefreshNotifier([
      _appStateNotifier,
      appStateProvider,
    ]);
    // Listener used previously for debug logging; removed to reduce log noise.
    // Start on the in-app splash to show initialization progress
    String initialPath = kIsWeb ? '/' : '/splash';
    if (kDebugMode) debugPrint('🧭 MyApp.initState: initialPath=$initialPath');
    _router = createRouter(
      _appStateNotifier,
      refresh: _refreshNotifier!,
      initialLocation: initialPath,
    );
    HWLog.lifecycle('app_init');

    // Watchdog removed to avoid build/runtime noise and API differences.
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshNotifier?.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    HWLog.lifecycle('lifecycle', data: {'state': state.name});
    if (state == AppLifecycleState.resumed) {
      _processOfflineQueueIfNeeded();
    }
  }
  
  void _processOfflineQueueIfNeeded() {
    try {
      final repositoryProvider = context.read<RepositoryProvider>();
      final repository = repositoryProvider.repository;
      if (repository is SupabaseWorkoutRepository) {
        repository.processOfflineQueue().catchError((error) {
          // Silently handle offline queue processing errors
        });
      }
    } catch (e) {
      // Silently handle repository access errors
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('🎯 MAIN APP BUILD()');
      HWLog.event('build_material_app_router');
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'HEAVYWEIGHT',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF111111),
        primaryColor: Colors.white,
        // Avoid GoogleFonts during diagnosis to ensure first paint
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xFF444444),
          surface: Color(0xFF111111),
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
            textStyle: const TextStyle(
              fontFamily: 'Rubik',
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
        cardTheme: const CardThemeData(
          color: Color(0xFF111111),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF111111),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: const TextStyle(
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
          labelStyle: const TextStyle(
            fontFamily: 'Rubik',
            color: Color(0xFF444444),
          ),
          hintStyle: const TextStyle(
            fontFamily: 'Rubik',
            color: Color(0xFF444444),
          ),
        ),
      ),
      themeMode: _themeMode,
      routerConfig: _router,
      // Ensure something paints even if routes misbehave
      builder: (context, child) {
        final isNull = child == null;
        if (kDebugMode) debugPrint('🧭 MaterialApp.router.builder: child=${isNull ? 'NULL' : child.runtimeType}');
        if (isNull) {
          return const Scaffold(
            backgroundColor: Color(0xFF111111),
            body: Center(
              child: Text(
                'BOOTING…',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          );
        }
        return ColoredBox(
          color: const Color(0xFF000000),
          child: child!,
        );
      },
    );
  }
}
