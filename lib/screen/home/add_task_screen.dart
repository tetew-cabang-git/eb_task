import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Daily Routine'; // Default category
  DateTime? _deadline;
  TimeOfDay? _time;
  Color _selectedColor = Colors.white;

  bool _isLoading = false;

  Future<void> _addTask() async {
    if (_nameController.text.isEmpty || _deadline == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Nama task, deadline, dan waktu wajib diisi")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mendapatkan user ID")),
        );
        return;
      }

      // Menggabungkan tanggal dan waktu untuk deadline
      final DateTime fullDeadline = DateTime(
        _deadline!.year,
        _deadline!.month,
        _deadline!.day,
        _time!.hour,
        _time!.minute,
      );

      // Masukkan data ke tabel task
      await _supabase.from('task').insert({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'deadline': fullDeadline.toIso8601String(),
        'card_color': _selectedColor.value.toString(),
        'category': _selectedCategory,
        'user_id': user.uid, // User ID dari Firebase
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task berhasil ditambahkan")),
      );

      setState(() {
        _nameController.text = '';
        _descriptionController.text = '';
        _deadline = null;
        _time = null;
        _selectedCategory = 'Daily Routine';
      });
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
      appBar: AppBar(
        title: const Center(
          child: Text("Add New Task"),
        ),
        backgroundColor: Colors.purple[100],
      ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Nama Task"),
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
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: "Deskripsi"),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Dropdown untuk kategori
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                            value: 'Daily Routine',
                            child: Text('Daily Routine')),
                        DropdownMenuItem(
                            value: 'Study Routine',
                            child: Text('Study Routine')),
                      ],
                      decoration: const InputDecoration(labelText: "Kategori"),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Pemilihan tanggal
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const Text("Pilih Deadline"),
                      subtitle: Text(_deadline == null
                          ? "Belum dipilih"
                          : _deadline!.toLocal().toString().split(' ')[0]),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != _deadline) {
                            setState(() {
                              _deadline = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Pemilihan waktu
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const Text("Pilih Waktu"),
                      subtitle: Text(_time == null
                          ? "Belum dipilih"
                          : "${_time!.hour}:${_time!.minute.toString().padLeft(2, '0')}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: _time ?? TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              _time = pickedTime;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Pemilihan warna
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const Text("Pilih Warna Card"),
                      trailing: CircleAvatar(
                        backgroundColor: _selectedColor,
                      ),
                      onTap: () async {
                        final Color? picked = await showDialog<Color>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Pilih Warna"),
                              content: SingleChildScrollView(
                                child: BlockPicker(
                                  pickerColor: _selectedColor,
                                  onColorChanged: (color) {
                                    Navigator.pop(context, color);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                        if (picked != null && picked != _selectedColor) {
                          setState(() {
                            _selectedColor = picked;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _addTask,
                        child: const Text("Tambahkan Task"),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
