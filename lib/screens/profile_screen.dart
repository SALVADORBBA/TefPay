import 'package:flutter/material.dart';
import '../models/machine_config.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatelessWidget {
  final MachineConfig machine;
  const ProfileScreen({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final p = machine.partner;
    final b = machine.beneficiary;
    final u = machine.systemUnit;

    return Scaffold(
      body: SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 32),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.point_of_sale,
                      size: 40, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(machine.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text('ID: ${machine.id}  •  Smart POS',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: machine.active
                        ? Colors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    machine.active ? '● ATIVA' : '● INATIVA',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Máquina
                _Section(
                  icon: Icons.memory,
                  title: 'Máquina',
                  items: [
                    _Item('Nome', machine.name),
                    _Item('ID', '${machine.id}'),
                    if (machine.serialNumber != null)
                      _Item('Serial', machine.serialNumber!),
                    _Item('Chave de Ativação',
                        machine.activationKey.substring(0, 8) + '…'),
                  ],
                ),

                // Parceiro
                _Section(
                  icon: Icons.business,
                  title: 'Parceiro',
                  items: [
                    _Item('Nome', p.name),
                    if (p.document != null) _Item('CNPJ', p.document!),
                    if (p.phone != null) _Item('Telefone', p.phone!),
                    if (p.email != null) _Item('E-mail', p.email!),
                    if (p.domain != null) _Item('Domínio', p.domain!),
                  ],
                ),

                // Beneficiário
                if (b != null)
                  _Section(
                    icon: Icons.person,
                    title: 'Beneficiário',
                    items: [
                      _Item('Nome', b.name),
                      if (b.document != null) _Item('Documento', b.document!),
                      if (b.phone != null) _Item('Telefone', b.phone!),
                      if (b.email != null) _Item('E-mail', b.email!),
                      if (b.type != null)
                        _Item('Tipo', b.type == 'company' ? 'Empresa' : 'Pessoa Física'),
                      if (b.cidade != null)
                        _Item('Endereço',
                            [b.logradouro, b.numero, b.bairro, b.cidade, b.estado]
                                .where((e) => e != null)
                                .join(', ')),
                    ],
                  ),

                // Unidade
                if (u != null)
                  _Section(
                    icon: Icons.store,
                    title: 'Unidade do Sistema',
                    items: [
                      _Item('Nome', u.name),
                      if (u.document != null) _Item('Documento', u.document!),
                      if (u.phone != null) _Item('Telefone', u.phone!),
                      if (u.cidade != null)
                        _Item('Cidade', '${u.cidade} - ${u.estado}'),
                    ],
                  ),

                // Desativar
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _confirmDesativar(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Desativar esta maquininha',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _confirmDesativar(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Desativar maquininha?'),
        content: const Text(
            'Os dados locais serão removidos e você precisará ativar novamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.clear();
              if (!context.mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/welcome', (_) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> items;
  const _Section({required this.icon, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14)),
              ],
            ),
            const Divider(height: 16),
            ...items,
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final String value;
  const _Item(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }
}
