import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/memory_provider.dart';
import 'services/security_manager.dart';
import 'screens/auth_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/biometric_registration_screen.dart';
import 'screens/memory_list_screen.dart';

void main() {
  runApp(const TimeLockApp());
}

class TimeLockApp extends StatelessWidget {
  const TimeLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemoryProvider()),
      ],
      child: MaterialApp(
        title: 'TimeLock - Digital Memory App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF16213E),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: const Color(0xFFE94560).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF16213E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE94560),
                width: 2,
              ),
            ),
          ),
        ),
        initialRoute: '/auth',
        routes: {
          '/auth': (context) => const AuthScreen(),
          '/setup': (context) => const SetupScreen(),
          '/biometric-registration': (context) => const BiometricRegistrationScreen(),
          '/home': (context) => const MemoryListScreen(),
        },
      ),
    );
  }
}
