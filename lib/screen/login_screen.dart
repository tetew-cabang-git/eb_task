import 'package:eb_task/screen/login_email_screen.dart';
import 'package:eb_task/screen/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _loginWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> _loginWithEmailPassword(BuildContext context) async {
    // Dummy email/password login
    // await FirebaseAuth.instance.signInWithEmailAndPassword(
    //   email: "testing@gmail.com",
    //   password: "123456",
    // );
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const LoginEmailScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _loginWithEmailPassword(context),
              child: const Text("Login with Email"),
            ),
            ElevatedButton(
              onPressed: _loginWithGoogle,
              child: const Text("Login with Google"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()));
              },
              child: const Text("Belum punya akun?"),
            ),
          ],
        ),
      ),
    );
  }
}
