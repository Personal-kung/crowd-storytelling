import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Fixes 'Firebase'
import 'firebase_options.dart'; // This will work AFTER Step 1
import 'editor_dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "env");
  // This initializes Firebase using the generated file
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Fixes 'DefaultFirebaseOptions'
  );

  runApp(const CuratorApp());
}

class CuratorApp extends StatelessWidget {
  const CuratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notebook Curator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // In a real app, you'd use a StreamBuilder here to check Firebase Auth
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() {
    // For now, we'll use a simple bypass.
    // Integrate Firebase Auth 'signInWithEmailAndPassword' here later.
    if (_emailController.text == "admin" &&
        _passwordController.text == "password") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const EditorDashboard()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid Credentials")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_stories, size: 64, color: Colors.blueGrey),
              const SizedBox(height: 20),
              Text(
                "Curator Portal",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Admin Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Enter Dashboard"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
