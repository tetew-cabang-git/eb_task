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
  final TextEditingController _categoryController = TextEditingController();
  DateTime? _deadline;
  Color _selectedColor = Colors.white;

  bool _isLoading = false;

  Future<void> _addTask() async {
    if (_nameController.text.isEmpty || _deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama task dan deadline wajib diisi")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Ambil user ID dari Firebase
      final user = _auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mendapatkan user ID")),
        );
        return;
      }

      // Masukkan data ke tabel task
      await _supabase.from('task').insert({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'deadline': _deadline!.toIso8601String(),
        'card_color': _selectedColor.value.toString(),
        'category': _categoryController.text,
        'user_id': user.uid, // User ID dari Firebase
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task berhasil ditambahkan")),
      );

      setState(() {
        _nameController.text = '';
        _descriptionController.text = '';
        _deadline = null;
        _categoryController.text = '';
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
      appBar: AppBar(title: const Text("Tambah Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nama Task"),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Deskripsi"),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: "Kategori"),
            ),
            const SizedBox(height: 16),
            ListTile(
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
            const SizedBox(height: 16),
            ListTile(
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
    );
  }
}
