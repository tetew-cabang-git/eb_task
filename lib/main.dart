import 'package:eb_task/screen/login_screen.dart';
import 'package:eb_task/main_screen.dart';
import 'package:eb_task/screen/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart'; // File ini di-generate oleh Firebase CLI

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://titgyomjfaucatkmhqba.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpdGd5b21qZmF1Y2F0a21ocWJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM3MzExMDEsImV4cCI6MjA0OTMwNzEwMX0.y_ukcogYWjIrthMNAJfXrWozqHUi7wIMfLsbJyTmgwU',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          : const MainScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
