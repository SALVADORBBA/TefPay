import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/machine_config.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/activation_screen.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const TefPayApp());
}

// Tema global atualizável após ativação
class AppThemeNotifier extends ChangeNotifier {
  ThemeData _theme = AppTheme.build();
  ThemeData get theme => _theme;

  void applyMachine(MachineConfig machine) {
    _theme = AppTheme.build(
      primaryHex: machine.partner.primaryColor,
      secondaryHex: machine.partner.secondaryColor,
      accentHex: machine.partner.accentColor,
    );
    notifyListeners();
  }

  void reset() {
    _theme = AppTheme.build();
    notifyListeners();
  }
}

final appThemeNotifier = AppThemeNotifier();

class TefPayApp extends StatefulWidget {
  const TefPayApp({super.key});
  @override
  State<TefPayApp> createState() => _TefPayAppState();
}

class _TefPayAppState extends State<TefPayApp> {
  @override
  void initState() {
    super.initState();
    appThemeNotifier.addListener(() => setState(() {}));
    _preloadTheme();
  }

  Future<void> _preloadTheme() async {
    final m = await StorageService.load();
    if (m != null) appThemeNotifier.applyMachine(m);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TefPay',
      debugShowCheckedModeBanner: false,
      theme: appThemeNotifier.theme,
      home: const SplashScreen(),
      routes: {
        '/welcome':    (_) => const WelcomeScreen(),
        '/activation': (_) => const ActivationScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final machine = settings.arguments as MachineConfig?;
          if (machine != null) {
            return MaterialPageRoute(
                builder: (_) => MainShell(machine: machine));
          }
          // fallback: recarrega do storage
          return MaterialPageRoute(builder: (ctx) {
            return FutureBuilder<MachineConfig?>(
              future: StorageService.load(),
              builder: (ctx2, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                }
                if (snap.data == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacementNamed(ctx2, '/welcome');
                  });
                  return const Scaffold(body: SizedBox());
                }
                return MainShell(machine: snap.data!);
              },
            );
          });
        }
        return null;
      },
    );
  }
}
