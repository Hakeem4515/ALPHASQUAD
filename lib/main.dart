import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/alphasquad_onboarding.dart';
import 'screens/alphasquad_login.dart';
import 'screens/alphasquad_register.dart';
import 'screens/main_navigation_hub.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Initialize FCM — request permissions and set up foreground/background handlers
  final notifService = NotificationService();
  await notifService.initialize();
  await notifService.requestPermissions();

  runApp(const AlphaSquadApp());
}

class AlphaSquadApp extends StatelessWidget {
  const AlphaSquadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOLARX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF6FAFD),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const AlphaSquadOnboardingScreen(),
        '/login': (context) => const AlphaSquadLoginScreen(),
        '/register': (context) => const AlphaSquadRegisterScreen(),
        '/home': (context) => const MainNavigationHub(),
      },
    );
  }
}
