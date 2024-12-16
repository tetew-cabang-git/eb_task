import 'package:eb_task/widgets/app_button.dart';
import 'package:eb_task/widgets/app_or_divider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:icons_plus/icons_plus.dart';
import '../main_screen.dart';

class LoginEmailScreen extends StatefulWidget {
  const LoginEmailScreen({super.key});

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan";
      if (e.code == 'user-not-found') {
        message = "Pengguna tidak ditemukan.";
      } else if (e.code == 'wrong-password') {
        message = "Password salah.";
      } else if (e.code == 'invalid-email') {
        message = "Email tidak valid.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kesalahan: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg2.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 72),
            child: Column(
              children: [
                const Text(
                  'Login To HabitHub',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC67ED2),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  'Welcome back! Sign in using your social account or email to continue us',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 18,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Brand(Brands.facebook),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Brand(Brands.google),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Brand(Brands.apple_logo),
                    ),
                  ],
                ),
                AppDivider.divider,
                const SizedBox(
                  height: 72,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration:
                                const InputDecoration(labelText: "Email"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email tidak boleh kosong";
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return "Masukkan email yang valid";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration:
                                const InputDecoration(labelText: "Password"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password tidak boleh kosong";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: 210,
                              height: 60,
                              child: AppButton.btnRegular(
                                  onPressed: _login,
                                  txtLabel: const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 24),
                                  )),
                            ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          "Belum punya akun? Daftar",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
