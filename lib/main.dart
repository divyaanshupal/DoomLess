import 'package:distract/dashboard.dart';
import 'package:distract/splash.dart';
import 'package:distract/accessibility_consent_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool hasConsented = prefs.getBool('accessibility_consented') ?? false;

  bool isAccessibilityEnabled = false;
  try {
    const platform = MethodChannel('com.example.distract/channel');
    isAccessibilityEnabled = await platform.invokeMethod<bool>('isAccessibilityEnabled') ?? false;
  } catch (e) {
    debugPrint('Error checking accessibility status: $e');
  }

  // We only navigate straight to Dashboard if user consented AND permission is currently active
  final bool shouldGoToDashboard = hasConsented && isAccessibilityEnabled;

  runApp(MyApp(shouldGoToDashboard: shouldGoToDashboard));
}

class MyApp extends StatelessWidget {
  final bool shouldGoToDashboard;

  MyApp({super.key, required this.shouldGoToDashboard});

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(
        onDone: () {
          _navigatorKey.currentState?.pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => shouldGoToDashboard
                  ? const DashboardScreen()
                  : const AccessibilityConsentScreen(),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        },
      ),
    );
  }
}