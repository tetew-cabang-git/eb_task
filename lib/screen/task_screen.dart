import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<dynamic> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ambil user ID dari Firebase
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mendapatkan user ID")),
        );
        return;
      }

      // Fetch tasks dengan filter berdasarkan user_id
      final response = await _supabase
          .from('task')
          .select()
          .eq('user_id', user.uid) // Filter berdasarkan user_id
          .order('deadline', ascending: true);

      setState(() {
        _tasks = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kesalahan saat mengambil tugas: $e")),
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
      appBar: AppBar(
        title: const Text("Tasks"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchTasks, // Method untuk refresh
              child: _tasks.isEmpty
                  ? const Center(
                      child: Text("Belum ada tugas. Tambahkan tugas baru."),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Card(
                          color: Color(int.parse(task['card_color'])),
                          child: ListTile(
                            title: Text(task['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task['description']),
                                Text(
                                  "Deadline: ${task['deadline']}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "Category: ${task['category']}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
