import 'package:flutter/material.dart';

import 'auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await AuthService().signIn();
          },

          child: const Text("Sign in with Google"),
        ),
      ),
    );
  }
}
