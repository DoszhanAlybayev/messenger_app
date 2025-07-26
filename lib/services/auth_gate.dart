import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger_app/pages/home_page.dart'; // Путь к HomePage
import 'package:messenger_app/pages/login_page.dart'; // Путь к LoginPage

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Пользователь залогинен
          if (snapshot.hasData) {
            return const HomePage();
          }
          // Пользователь НЕ залогинен
          else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}