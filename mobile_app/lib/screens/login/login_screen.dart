import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_rail/screens/shell/app_shell.dart';
import 'package:smart_rail/services/api_service.dart';
import 'package:smart_rail/services/session.dart';
import 'package:smart_rail/utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final employee = TextEditingController();
  final password = TextEditingController();
  final server = TextEditingController();
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final api = context.read<SessionController>().api;
    server.text = api.baseUrl;
  }

  @override
  void dispose() {
    employee.dispose();
    password.dispose();
    server.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final session = context.read<SessionController>();
      await session.api.setBaseUrl(server.text.trim());
      await session.login(
            employee.text.trim(),
            password.text,
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } on ApiException catch (e) {
      setState(() => error = e.message);
    } catch (_) {
      setState(() => error = 'Cannot reach server. Check Wi-Fi and laptop IP.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.train,
                      size: 64,
                      color: SmartRailTheme.navy,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'SmartRail AI',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: SmartRailTheme.navy,
                letterSpacing: 0.4,
              ),
            ),
            const Text(
              'Indian Railways Track Asset Operations',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: employee,
              decoration: const InputDecoration(
                labelText: 'Employee ID',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: server,
              decoration: const InputDecoration(
                labelText: 'Backend URL (laptop IP)',
                prefixIcon: Icon(Icons.dns_outlined),
                helperText: 'Example: http://10.18.72.137:5000',
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: const TextStyle(color: SmartRailTheme.danger)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : _login,
              child: Text(loading ? 'Signing in...' : 'LOGIN'),
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text('Forgot password?'),
                    content: Text(
                      'Ask the SmartRail admin to reset your password from the Users screen. Email reset is not used in this college prototype.',
                    ),
                  ),
                );
              },
              child: const Text('Forgot Password?'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Demo: ADMIN001 / Admin@123\nINSP001 / Inspect@123\nMAINT001 / Maint@123',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
