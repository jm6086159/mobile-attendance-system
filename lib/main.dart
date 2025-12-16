import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/attendance_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MobileAttendanceApp());
}

class MobileAttendanceApp extends StatelessWidget {
  const MobileAttendanceApp({super.key});

  static const Color _brandGreen = Color(0xFF0F8B48);
  static const Color _brandGold  = Color(0xFFE8B400);
  static const Color _brandNavy  = Color(0xFF0A1F3B);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Initialize auth on startup so refresh works
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: MaterialApp(
        title: 'Mobile Attendance',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: _brandGreen,
            primary: _brandGreen,
            secondary: _brandGold,
            background: _brandNavy,
            surface: Colors.white,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
          scaffoldBackgroundColor: _brandNavy,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _brandGreen.withOpacity(.25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _brandGreen, width: 1.4),
            ),
            labelStyle: const TextStyle(color: Colors.black87),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
          textTheme: const TextTheme(
            headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            titleMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
            bodyMedium: TextStyle(color: Colors.black87),
            bodySmall: TextStyle(color: Colors.black87),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          // Guard home behind auth so hard refresh on /#home still checks state
          '/home': (context) => const _HomeGate(),
        },
      ),
    );
  }
}

class _HomeGate extends StatefulWidget {
  const _HomeGate();
  @override
  State<_HomeGate> createState() => _HomeGateState();
}

class _HomeGateState extends State<_HomeGate> {
  @override
  void initState() {
    super.initState();
    // Ensure auth is initialized if user refreshed on /#home
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      if (!auth.isInitializing && !auth.isAuthenticated) {
        await auth.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isInitializing) {
      return const SplashScreen();
    }
    if (!auth.isAuthenticated) return const LoginScreen();
    return const HomeScreen();
  }
}






