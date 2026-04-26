import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/machine_config.dart';
import '../services/api_service.dart';

class MonitorScreen extends StatefulWidget {
  final MachineConfig machine;
  const MonitorScreen({super.key, required this.machine});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  List<Pagamento> _pagamentos = [];
  bool _loading = true;
  String? _error;
  Timer? _timer;
  String _filtro = 'todos';
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetch();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetch());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final status = _filtro == 'todos' ? null : _filtro;
      final list = await ApiService.listPagamentos(
          widget.machine.activationKey,
          status: status);
      if (mounted) {
        setState(() {
          _pagamentos = list;
          _loading = false;
          _error = null;
          _lastUpdate = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final fmt = DateFormat('HH:mm:ss');

    return Scaffold(
      body: Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          color: primary,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monitor, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Monitor TEF',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.circle,
                              size: 8, color: Color(0xFF4ADE80)),
                          const SizedBox(width: 6),
                          Text(fmt.format(_lastUpdate),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () { setState(() => _loading = true); _fetch(); },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(widget.machine.name,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ),

        // Filtros
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final f in ['todos', 'pending', 'approved', 'declined'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_filtroLabel(f)),
                      selected: _filtro == f,
                      onSelected: (_) {
                        setState(() { _filtro = f; _loading = true; });
                        _fetch();
                      },
                      selectedColor: primary.withOpacity(0.15),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Lista
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _ErrorView(error: _error!, onRetry: _fetch)
                  : _pagamentos.isEmpty
                      ? const _EmptyView()
                      : RefreshIndicator(
                          onRefresh: _fetch,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _pagamentos.length,
                            itemBuilder: (_, i) =>
                                _PagamentoCard(pagamento: _pagamentos[i]),
                          ),
                        ),
        ),
      ],
      ),
    );
  }

  String _filtroLabel(String f) {
    switch (f) {
      case 'todos':    return 'Todos';
      case 'pending':  return 'Pendentes';
      case 'approved': return 'Aprovados';
      case 'declined': return 'Recusados';
      default: return f;
    }
  }
}

class _PagamentoCard extends StatelessWidget {
  final Pagamento pagamento;
  const _PagamentoCard({required this.pagamento});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFmt = DateFormat('dd/MM HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _payColor(pagamento.paymentType).withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(_payIcon(pagamento.paymentType),
              color: _payColor(pagamento.paymentType), size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(fmt.format(pagamento.valorReais),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            _StatusChip(status: pagamento.status),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(pagamento.paymentTypeLabel,
                style: const TextStyle(fontSize: 13)),
            if (pagamento.descricao != null)
              Text(pagamento.descricao!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text('ID: ${pagamento.id}  •  ${_formatDate(pagamento.createdAt, dateFmt)}',
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'approved':  return Colors.green;
      case 'pending':   return Colors.orange;
      case 'declined':  return Colors.red;
      case 'cancelled': return Colors.grey;
      default:          return Colors.grey;
    }
  }

  IconData _payIcon(String t) {
    switch (t) {
      case 'credit':  return Icons.credit_card;
      case 'debit':   return Icons.credit_card_outlined;
      case 'pix':     return Icons.pix;
      case 'cash':    return Icons.money;
      default:        return Icons.payment;
    }
  }

  Color _payColor(String t) {
    switch (t) {
      case 'pix':    return const Color(0xFF7C3AED); // roxo
      case 'credit': return const Color(0xFF2563EB); // azul
      case 'debit':  return const Color(0xFF059669); // verde
      default:       return Colors.grey;
    }
  }

  String _formatDate(String raw, DateFormat fmt) {
    try {
      return fmt.format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'approved':  color = Colors.green; break;
      case 'pending':   color = Colors.orange; break;
      case 'declined':  color = Colors.red; break;
      default:          color = Colors.grey;
    }
    final labels = {
      'approved': 'Aprovado', 'pending': 'Pendente',
      'declined': 'Recusado', 'cancelled': 'Cancelado', 'error': 'Erro',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(labels[status] ?? status,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhum pagamento encontrado',
                style: TextStyle(color: Colors.grey, fontSize: 15)),
            SizedBox(height: 8),
            Text('Aguardando transações…',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
}
