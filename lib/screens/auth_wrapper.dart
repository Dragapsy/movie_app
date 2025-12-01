import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/prefs_service.dart';
import 'onboarding_screen.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PrefsService().hasSeenOnboarding(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final seen = snapshot.data ?? false;
        if (!seen) return const OnboardingScreen();
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnap) {
            if (authSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            // Afficher HomeScreen même si l'utilisateur n'est pas connecté, afin de voir les films sans authentification.
            return const HomeScreen();
          },
        );
      },
    );
  }
}
