import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/auth/login/login.dart';
import 'package:project/ui/auth/login/login_viewmodel.dart';
import 'package:project/app/settings_provider.dart';

class BoardGameBookingApp extends StatelessWidget {
  const BoardGameBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'BoardNest',
            themeMode: settings.themeMode,
            theme: ThemeData(
              scaffoldBackgroundColor: const Color(0xF9F9FFFF),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1275e2),
                primary: const Color(0xFF1275e2),
                secondary: const Color(0xFF5f78a3),
                tertiary: const Color(0xFFC55B00),
                surface: const Color(0xF9F9FFFF),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xF9F9FFFF),
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  color: Color(0xFF3A312C),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              cardTheme: CardThemeData(
                color: const Color(0xF9F9FFFF),
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1275e2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1275e2),
                brightness: Brightness.dark,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1275e2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}

