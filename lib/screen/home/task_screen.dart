import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, List<dynamic>> _groupedTasks = {};
  bool _isLoading = false;
  String _selectedCategory = 'All'; // Default category is 'All'

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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mendapatkan user ID")),
        );
        return;
      }

      final response = await _supabase
          .from('task')
          .select()
          .eq('user_id', user.uid)
          .order('deadline', ascending: true);

      final Map<String, List<dynamic>> groupedTasks = {};
      for (var task in response) {
        final deadlineDate = DateFormat('yyyy-MM-dd').format(
          DateTime.parse(task['deadline']),
        );

        // Filter berdasarkan kategori
        if (_selectedCategory != 'All' &&
            task['category'] != _selectedCategory) {
          continue;
        }

        if (!groupedTasks.containsKey(deadlineDate)) {
          groupedTasks[deadlineDate] = [];
        }
        groupedTasks[deadlineDate]!.add(task);
      }

      setState(() {
        _groupedTasks = groupedTasks;
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

  // Fungsi untuk mengubah status is_done menjadi true
  Future<void> _markTaskAsDone(int taskId) async {
    try {
      await _supabase
          .from('task')
          .update({'is_done': true}) // Set is_done menjadi true
          .eq('id', taskId); // Filter berdasarkan task ID

      _fetchTasks(); // Refresh daftar tugas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task berhasil diselesaikan!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyelesaikan task: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Tasks"),
        ),
        backgroundColor: Colors.purple[100],
      ),
      body: _isLoading
          ? Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/bg.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const Center(
                  child: CircularProgressIndicator(),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        color: _selectedCategory == 'All'
                            ? Colors.purple
                            : Colors.grey,
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'All';
                          });
                          _fetchTasks(); // Fetch ulang tugas setelah filter diubah
                        },
                        child: const Text('All',
                            style: TextStyle(color: Colors.white)),
                      ),
                      MaterialButton(
                        color: _selectedCategory == 'Daily Routine'
                            ? Colors.purple
                            : Colors.grey,
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'Daily Routine';
                          });
                          _fetchTasks();
                        },
                        child: const Text('Daily Routine',
                            style: TextStyle(color: Colors.white)),
                      ),
                      MaterialButton(
                        color: _selectedCategory == 'Study Routine'
                            ? Colors.purple
                            : Colors.grey,
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'Study Routine';
                          });
                          _fetchTasks();
                        },
                        child: const Text('Study Routine',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/bg.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        color: _selectedCategory == 'All'
                            ? Colors.purple
                            : Colors.grey,
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'All';
                          });
                          _fetchTasks(); // Fetch ulang tugas setelah filter diubah
                        },
                        child: const Text('All',
                            style: TextStyle(color: Colors.white)),
                      ),
                      MaterialButton(
                        color: _selectedCategory == 'Daily Routine'
                            ? Colors.purple
                            : Colors.grey,
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'Daily Routine';
                          });
                          _fetchTasks();
                        },
                        child: const Text('Daily Routine',
                            style: TextStyle(color: Colors.white)),
                      ),
                      MaterialButton(
                        color: _selectedCategory == 'Study Routine'
                            ? Colors.purple
                            : Colors.grey,
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'Study Routine';
                          });
                          _fetchTasks();
                        },
                        child: const Text('Study Routine',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: RefreshIndicator(
                    onRefresh: _fetchTasks,
                    child: _groupedTasks.isEmpty
                        ? const Center(
                            child:
                                Text("Belum ada tugas. Tambahkan tugas baru."),
                          )
                        : ListView.builder(
                            itemCount: _groupedTasks.keys.length,
                            itemBuilder: (context, index) {
                              String date = _groupedTasks.keys.elementAt(index);
                              List<dynamic> tasks = _groupedTasks[date]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header Tanggal
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                      color: Colors.grey[200],
                                    ),
                                    child: Text(
                                      DateFormat('EEEE, dd MMM yyyy').format(
                                        DateTime.parse(date),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  // Daftar Tugas
                                  ...tasks.map(
                                    (task) {
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        color: Color(
                                            int.parse(task['card_color'])),
                                        child: ListTile(
                                          title: Text(
                                            task['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              decoration: task['is_done'] ==
                                                      true
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration
                                                      .none, // Strikethrough jika is_done = true
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                task['description'],
                                                style: TextStyle(
                                                  decoration:
                                                      task['is_done'] == true
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration.none,
                                                ),
                                              ),
                                              Text(
                                                "Deadline: ${task['deadline']}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  decoration:
                                                      task['is_done'] == true
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration.none,
                                                ),
                                              ),
                                              Text(
                                                "Category: ${task['category']}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  decoration:
                                                      task['is_done'] == true
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration.none,
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: Radio<bool>(
                                            value: true,
                                            groupValue: task['is_done'] == true
                                                ? true
                                                : null, // Checked jika done
                                            onChanged: (value) {
                                              if (task['is_done'] != true) {
                                                _markTaskAsDone(task[
                                                    'id']); // Tandai task sebagai selesai
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ],
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
