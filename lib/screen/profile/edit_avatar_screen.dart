import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditAvatarScreen extends StatefulWidget {
  const EditAvatarScreen({Key? key}) : super(key: key);

  @override
  State<EditAvatarScreen> createState() => _EditAvatarScreenState();
}

class _EditAvatarScreenState extends State<EditAvatarScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadAvatar() async {
    if (_image == null) return;

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

      final fileName = '${user.uid}/avatar.png';
      final storageResponse = await _supabase.storage.from('avatars').upload(
            fileName,
            _image!,
          );

      if (storageResponse.isNotEmpty) {
        throw Exception("Upload gagal: ${storageResponse.characters}");
      }

      final avatarUrl =
          _supabase.storage.from('avatars').getPublicUrl(fileName);

      await _supabase
          .from('user')
          .update({'avatar': avatarUrl}).eq('email', user.email ?? '');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Avatar berhasil diperbarui")),
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
      appBar: AppBar(title: const Text("Edit Avatar")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: FileImage(_image!),
              )
            else
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/default_avatar.png'),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Pilih Gambar"),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadAvatar,
                    child: const Text("Simpan Avatar"),
                  ),
          ],
        ),
      ),
    );
  }
}
