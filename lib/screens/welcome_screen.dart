import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Column(
        children: [
          // Header azul
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: const Column(
              children: [
                Icon(Icons.point_of_sale, size: 80, color: Colors.white),
                SizedBox(height: 16),
                Text('Smart Pay',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 4),
                Text('Bem-vindo ao sistema',
                    style: TextStyle(color: Colors.white70, fontSize: 15)),
              ],
            ),
          ),

          const Spacer(),

          // Card de ativação
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.qr_code_scanner, size: 40, color: primary),
                    ),
                    const SizedBox(height: 16),
                    const Text('ATIVAR MAQUININHA',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'Escaneie o QR Code ou digite o código de ativação',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/activation'),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('ATIVAR AGORA'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Rodapé com info de ambiente
          FutureBuilder(
            future: StorageService.load(),
            builder: (_, snap) {
              final machine = snap.data;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.business,
                        label: 'Parceiro',
                        value: machine?.partner.name ?? '-',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.person,
                        label: 'Beneficiário',
                        value: machine?.beneficiary?.name ?? '-',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _InfoCard(
              icon: Icons.cloud,
              label: 'Ambiente',
              value: 'Produção',
              full: true,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool full;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.full = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
