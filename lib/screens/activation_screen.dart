import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/machine_config.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});
  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  bool _scanning = false;
  String? _error;
  MachineConfig? _found;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _buscar(String codigo) async {
    if (codigo.trim().isEmpty) return;
    setState(() { _loading = true; _error = null; _found = null; });
    try {
      final machine = await ApiService.findByCodigo(codigo.trim().toUpperCase());
      setState(() { _found = machine; _loading = false; });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Erro de conexão. Verifique sua internet.'; _loading = false; });
    }
  }

  Future<void> _ativar() async {
    if (_found == null) return;
    setState(() { _loading = true; });
    await StorageService.save(_found!);
    appThemeNotifier.applyMachine(_found!);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, '/main', (_) => false, arguments: _found);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text('Ativacao',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 16),
                const Icon(Icons.point_of_sale, size: 64, color: Colors.white),
                const SizedBox(height: 12),
                const Text('Ativar Maquininha',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Digite o codigo ou escaneie o QR Code',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Scanner QR
                  if (_scanning) ...[
                    SizedBox(
                      height: 260,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: MobileScanner(
                          onDetect: (capture) {
                            final code = capture.barcodes.first.rawValue;
                            if (code != null) {
                              setState(() => _scanning = false);
                              _controller.text = code;
                              _buscar(code);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => setState(() => _scanning = false),
                      icon: const Icon(Icons.close),
                      label: const Text('Fechar câmera'),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Campo de código
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Codigo de Ativacao',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.vpn_key, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  textCapitalization: TextCapitalization.characters,
                                  maxLength: 8,
                                  decoration: const InputDecoration(
                                    hintText: 'X X X X X X X X',
                                    border: InputBorder.none,
                                    counterText: '',
                                  ),
                                  style: const TextStyle(
                                      letterSpacing: 6,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  onChanged: (_) =>
                                      setState(() => _error = null),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    setState(() => _scanning = !_scanning),
                                icon: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.qr_code_scanner,
                                      color: Colors.white, size: 22),
                                ),
                              ),
                            ],
                          ),
                          ValueListenableBuilder(
                            valueListenable: _controller,
                            builder: (_, val, __) => Text(
                              '${val.text.length}/8',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(_error!,
                                  style: const TextStyle(color: Colors.red, fontSize: 13))),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () => _buscar(_controller.text),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('BUSCAR MAQUININHA',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),

                  // Preview da máquina encontrada
                  if (_found != null) ...[
                    const SizedBox(height: 24),
                    _MachinePreview(machine: _found!, onActivate: _ativar),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MachinePreview extends StatelessWidget {
  final MachineConfig machine;
  final VoidCallback onActivate;

  const _MachinePreview({required this.machine, required this.onActivate});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(machine.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('ID: ${machine.id}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _Row('Parceiro', machine.partner.name),
            if (machine.beneficiary != null)
              _Row('Beneficiário', machine.beneficiary!.name),
            if (machine.systemUnit != null)
              _Row('Unidade', machine.systemUnit!.name),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onActivate,
                icon: const Icon(Icons.flash_on),
                label: const Text('ATIVAR ESTA MAQUININHA',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _Row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Text('$label: ',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
      );
}
