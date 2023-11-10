import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sk_app/screens/auth/landing_screen.dart';
import 'package:sk_app/screens/auth/login_screen.dart';
import 'package:sk_app/screens/home_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'sk-app-56284',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SK App',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state, you can show a loading indicator here if needed
            return const CircularProgressIndicator();
          }

          User? user = snapshot.data;

          if (user != null) {
            if (user.emailVerified) {
              // User is logged in and email is verified, navigate to HomeScreen
              return HomeScreen();
            } else {
              // User is logged in and email is verified, pero kung eh home, dli mo balik sa loginScreen
              return HomeScreen();
            }
          }
          // User is not logged in, navigate to LoginScreen
          return LoginScreen();
        },
      ),
    );
  }
}
