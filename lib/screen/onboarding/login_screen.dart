import 'package:eb_task/screen/onboarding/login_email_screen.dart';
import 'package:eb_task/screen/onboarding/register_screen.dart';
import 'package:eb_task/widgets/app_button.dart';
import 'package:eb_task/widgets/app_or_divider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Future<void> _loginWithGoogle() async {
  //   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //   final GoogleSignInAuthentication googleAuth =
  //       await googleUser!.authentication;

  //   final credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth.accessToken,
  //     idToken: googleAuth.idToken,
  //   );

  //   await FirebaseAuth.instance.signInWithCredential(credential);
  // }
  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      // Inisialisasi Firebase Auth dan Google Sign-In
      final FirebaseAuth auth = FirebaseAuth.instance;
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Login dengan Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login dibatalkan oleh pengguna.')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Validasi token Google
      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Google Sign-In gagal mendapatkan token.')),
        );
        return;
      }

      // Kredensial Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login ke Firebase
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final String uid = firebaseUser.uid;
        final String email = firebaseUser.email ?? '';
        final String displayName = firebaseUser.displayName ?? 'Anonymous';
        final String avatarUrl = firebaseUser.photoURL ?? '';

        // Supabase: cek atau tambahkan user
        final supabase = Supabase.instance.client;
        final response = await supabase
            .from('user')
            .select()
            .eq('email', email)
            .maybeSingle();

        if (response == null || response.isEmpty) {
          // Tambahkan user ke Supabase jika belum ada
          await supabase.from('user').insert({
            'id': uid,
            'email': email,
            'username': email.split('@')[0],
            'first_name': displayName.split(' ').first,
            'last_name': displayName.split(' ').length > 1
                ? displayName.split(' ').last
                : '',
            'avatar': avatarUrl,
          });
        }

        // Navigasi ke halaman utama
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        throw FirebaseAuthException(
            code: 'null-user', message: 'Pengguna tidak ditemukan.');
      }
    } catch (e, stacktrace) {
      // Tampilkan error untuk debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: ${e.toString()}')),
      );
      debugPrint(stacktrace.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Login")),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 64, left: 24),
                child: Column(
                  children: [
                    Text(
                      'Do your task quickly and easy',
                      style: TextStyle(
                        fontSize: 64,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your task, your rules, our support',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              SizedBox(
                width: 215,
                height: 60,
                child: AppButton.btnRegular(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginEmailScreen(),
                      ),
                    );
                  },
                  txtLabel: const Text(
                    'Login',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Belum punya akun?',
                  style: TextStyle(
                    fontSize: 12,
                    // decoration: TextDecoration.underline,
                    // decorationThickness: 2,
                    // decorationColor: Colors.deepPurple,
                  ),
                ),
              ),
              AppDivider.divider,
              const SizedBox(
                height: 4,
              ),
              IconButton(
                onPressed: () async {
                  loginWithGoogle(context);
                },
                icon: Brand(Brands.google),
              ),
            ],
          )
        ],
      ),
    );
  }
}
