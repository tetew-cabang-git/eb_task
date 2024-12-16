import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateNameScreen extends StatefulWidget {
  const UpdateNameScreen({Key? key}) : super(key: key);

  @override
  State<UpdateNameScreen> createState() => _UpdateNameScreenState();
}

class _UpdateNameScreenState extends State<UpdateNameScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updateName() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mendapatkan pengguna")),
        );
        return;
      }

      await _supabase.from('user').update({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
      }).eq('email', user.email ?? '');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama berhasil diperbarui")),
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
      appBar: AppBar(title: const Text("Update Name")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: "First Name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: "Last Name"),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updateName,
                    child: const Text("Update Name"),
                  ),
          ],
        ),
      ),
    );
  }
}
