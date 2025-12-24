import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_panel.dart';
import 'screens/event_details_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/add_event_screen.dart';
import 'models/event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoginScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/admin': (context) => const AdminPanel(),
          '/add_event': (context) => const AddEventScreen(),
          '/event_details': (context) => EventDetailsScreen(event: ModalRoute.of(context)!.settings.arguments as Event),
          '/profile': (context) => const UserProfileScreen(),
        },
      ),
    );
  }
}
