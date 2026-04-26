import 'package:flutter/material.dart';
import '../models/machine_config.dart';
import 'monitor_screen.dart';
import 'calculator_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  final MachineConfig machine;
  const MainShell({super.key, required this.machine});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  late final MonitorScreen _monitor;
  late final CalculatorScreen _calculator;
  late final ProfileScreen _profile;

  @override
  void initState() {
    super.initState();
    _monitor    = MonitorScreen(machine: widget.machine);
    _calculator = CalculatorScreen(
      machine: widget.machine,
      onPaymentCreated: () => setState(() => _tab = 0), // vai para Monitor
    );
    _profile = ProfileScreen(machine: widget.machine);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [_monitor, _calculator, _profile],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        indicatorColor: primary.withAlpha(30),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.monitor_outlined),
            selectedIcon: Icon(Icons.monitor),
            label: 'Monitor',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Calculadora',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
