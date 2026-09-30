import 'package:flutter/foundation.dart';
import 'package:smart_rail/services/api_service.dart';

class SessionController extends ChangeNotifier {
  final api = ApiClient.instance;
  Map<String, dynamic>? user;
  bool ready = false;

  String get name => user?['name']?.toString() ?? 'User';
  String get role => user?['role']?.toString() ?? '';
  bool get isAdmin => role == 'ADMIN';
  bool get isInspector => role == 'INSPECTOR';
  bool get isMaintenance => role == 'MAINTENANCE';
  bool get loggedIn => api.token != null && user != null;

  Future<void> load() async {
    await api.load();
    if (api.token != null) {
      try {
        user = Map<String, dynamic>.from(await api.get('/api/auth/me'));
      } catch (_) {
        await api.setToken(null);
        user = null;
      }
    }
    ready = true;
    notifyListeners();
  }

  Future<void> login(String employeeId, String password) async {
    final data = await api.post('/api/auth/login', {
      'employee_id': employeeId,
      'password': password,
    });
    await api.setToken(data['token'] as String);
    user = Map<String, dynamic>.from(data['user'] as Map);
    notifyListeners();
  }

  Future<void> logout() async {
    await api.setToken(null);
    user = null;
    notifyListeners();
  }
}
