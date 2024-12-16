import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mendapatkan data pengguna")),
        );
        return;
      }

      final response = await _supabase
          .from('user')
          .select()
          .eq('email', user.email ?? '')
          .single();

      setState(() {
        _profileData = response;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kesalahan: $e")),
      );
    }
  }

  void _logOut() async {
    await _auth.signOut();
    Navigator.of(context)
        .pushReplacementNamed('/login'); // Navigasi ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                _profileData?['username'] ?? 'Pengguna',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Update Avatar"),
              onTap: () {
                Navigator.pushNamed(context, '/edit_avatar');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Update First Name & Last Name"),
              onTap: () {
                Navigator.pushNamed(context, '/update_name');
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Update Email"),
              onTap: () {
                Navigator.pushNamed(context, '/update_email');
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Edit Password"),
              onTap: () {
                Navigator.pushNamed(context, '/edit_password');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Log Out"),
              onTap: _logOut,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileData?['avatar'] != null
                          ? NetworkImage(_profileData!['avatar'])
                          : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Username: ${_profileData?['username'] ?? 'Tidak tersedia'}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "First Name: ${_profileData?['first_name'] ?? 'Tidak tersedia'}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Last Name: ${_profileData?['last_name'] ?? 'Tidak tersedia'}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Email: ${_profileData?['email'] ?? 'Tidak tersedia'}",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
    );
  }
}
