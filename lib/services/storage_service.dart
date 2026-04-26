import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/machine_config.dart';

class StorageService {
  static const _keyMachine = 'machine_config';

  static Future<void> save(MachineConfig machine) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMachine, jsonEncode(machine.toJson()));
  }

  static Future<MachineConfig?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyMachine);
    if (raw == null) return null;
    try {
      return MachineConfig.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMachine);
  }
}
