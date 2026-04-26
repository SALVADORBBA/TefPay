import 'package:flutter/material.dart';
import '../main.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding garante que o frame foi renderizado antes de navegar
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    final machine = await StorageService.load();

    if (!mounted) return;

    if (machine == null || machine.activationKey.isEmpty) {
      Navigator.pushReplacementNamed(context, '/welcome');
      return;
    }

    // Valida na API se ainda está ativa
    try {
      final updated = await ApiService.findById(machine.id);
      if (!mounted) return;
      if (updated.active) {
        await StorageService.save(updated);
        appThemeNotifier.applyMachine(updated);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/main', arguments: updated);
      } else {
        await StorageService.clear();
        appThemeNotifier.reset();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    } catch (_) {
      // Sem internet: usa dados locais
      if (!mounted) return;
      appThemeNotifier.applyMachine(machine);
      Navigator.pushReplacementNamed(context, '/main', arguments: machine);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF2563EB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.point_of_sale, size: 80, color: Colors.white),
            SizedBox(height: 24),
            Text('TefPay',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 8),
            Text('Smart POS',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            SizedBox(height: 48),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
