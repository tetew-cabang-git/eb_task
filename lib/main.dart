import 'package:eb_task/screen/profile/edit_avatar_screen.dart';
import 'package:eb_task/screen/profile/edit_password_screen.dart';
import 'package:eb_task/screen/onboarding/login_screen.dart';
import 'package:eb_task/screen/main_screen.dart';
import 'package:eb_task/screen/onboarding/register_screen.dart';
import 'package:eb_task/screen/profile/update_email_screen.dart';
import 'package:eb_task/screen/profile/update_name_screen.dart';
import 'package:eb_task/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart'; // File ini di-generate oleh Firebase CLI

Future<void> checkTasksAndNotify() async {
  final supabase = Supabase.instance.client;

  // Dapatkan waktu sekarang
  final now = DateTime.now();

  // Fetch task dari Supabase yang belum selesai dan deadline-nya mendekati H-1
  final response =
      await supabase.from('task').select().filter('done', 'eq', false);

  if (response.isNotEmpty) {
    final tasks = response as List<dynamic>;

    for (var task in tasks) {
      final DateTime deadline = DateTime.parse(task['deadline']);
      final difference = deadline.difference(now).inDays;

      // Jika mendekati H-1, kirimkan notifikasi
      if (difference == 1) {
        await NotificationService.showNotification(
          title: 'Pengingat Task',
          body: 'Task "${task['name']}" akan jatuh tempo besok!',
        );
      }
    }
  } else {
    print('Error fetching tasks: $response');
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await NotificationService.initialize();
    await checkTasksAndNotify();
    return Future.value(true);
  });
}

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
  await NotificationService.initialize();
  Workmanager().initialize(callbackDispatcher);

  // Jadwalkan background task
  Workmanager().registerPeriodicTask(
    "checkTasks",
    "checkTasks",
    frequency: const Duration(hours: 24), // Jalankan setiap 24 jam
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          : const MainScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/update_name': (context) => const UpdateNameScreen(),
        '/update_email': (context) => const UpdateEmailScreen(),
        '/edit_password': (context) => const EditPasswordScreen(),
        '/edit_avatar': (context) => const EditAvatarScreen(),
      },
    );
  }
}
