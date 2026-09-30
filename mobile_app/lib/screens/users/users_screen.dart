import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_rail/services/api_service.dart';
import 'package:smart_rail/services/session.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<Map<String, dynamic>> users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await context.read<SessionController>().api.get('/api/users');
    setState(() {
      users = List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
      loading = false;
    });
  }

  Future<void> _add() async {
    final session = context.read<SessionController>();
    final employee = TextEditingController();
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    String role = 'INSPECTOR';
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add user'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: employee, decoration: const InputDecoration(labelText: 'Employee ID')),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: password, decoration: const InputDecoration(labelText: 'Password')),
              DropdownButtonFormField<String>(
                initialValue: role,
                items: const [
                  DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                  DropdownMenuItem(value: 'INSPECTOR', child: Text('INSPECTOR')),
                  DropdownMenuItem(value: 'MAINTENANCE', child: Text('MAINTENANCE')),
                ],
                onChanged: (value) => role = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (saved != true) return;
    try {
      await session.api.post('/api/users', {
        'employee_id': employee.text.trim(),
        'name': name.text.trim(),
        'email': email.text.trim(),
        'password': password.text,
        'role': role,
      });
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.person_add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, i) {
                final user = users[i];
                return ListTile(
                  title: Text(user['name']?.toString() ?? ''),
                  subtitle: Text('${user['employee_id']} · ${user['role']}'),
                );
              },
            ),
    );
  }
}
