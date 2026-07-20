import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'features/capture/presentation/capture_screen.dart';
import 'core/auth/login_screen.dart';

class GlobalNotebookApp extends StatelessWidget {
  const GlobalNotebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Notebook',

      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const CaptureScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
