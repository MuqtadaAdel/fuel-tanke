import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finalproject/screen/home_screen.dart';
import 'package:finalproject/screen/login_screen.dart';
//import 'package:fuel_tanker_app/src/home/home_page.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            // مستخدم غير مسجل
            return const LoginPage();
          } else {
            // مستخدم مسجل
            return const HomePage();
         }
        }
        // شاشة انتظار أثناء التحقق
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
