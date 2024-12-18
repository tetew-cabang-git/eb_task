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
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.purple[100],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.pinkAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileData?['avatar'] != null
                                ? NetworkImage(_profileData!['avatar'])
                                : const AssetImage('assets/default_avatar.png')
                                    as ImageProvider,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _profileData?['username'] ?? 'Tidak tersedia',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _profileData?['email'] ?? 'Tidak tersedia',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const Divider(
                          color: Colors.white70,
                          height: 40,
                          thickness: 1,
                        ),
                        ProfileDetailCard(
                          title: "First Name",
                          value:
                              _profileData?['first_name'] ?? 'Tidak tersedia',
                        ),
                        ProfileDetailCard(
                          title: "Last Name",
                          value: _profileData?['last_name'] ?? 'Tidak tersedia',
                        ),
                        ProfileDetailCard(
                          title: "Email",
                          value: _profileData?['email'] ?? 'Tidak tersedia',
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _logOut,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text("Log Out"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class ProfileDetailCard extends StatelessWidget {
  final String title;
  final String value;

  const ProfileDetailCard({required this.title, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        leading: const Icon(Icons.info_outline, color: Colors.purple),
      ),
    );
  }
}
