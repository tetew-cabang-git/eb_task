import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateEmailScreen extends StatefulWidget {
  const UpdateEmailScreen({Key? key}) : super(key: key);

  @override
  State<UpdateEmailScreen> createState() => _UpdateEmailScreenState();
}

class _UpdateEmailScreenState extends State<UpdateEmailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updateEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mendapatkan pengguna")),
        );
        return;
      }

      await user.verifyBeforeUpdateEmail(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email berhasil diperbarui")),
      );
      Navigator.pop(context);
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
      appBar: AppBar(title: const Text("Update Email")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "New Email"),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updateEmail,
                    child: const Text("Update Email"),
                  ),
          ],
        ),
      ),
    );
  }
}
