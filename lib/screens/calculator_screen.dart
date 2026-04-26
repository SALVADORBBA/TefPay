import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/machine_config.dart';
import '../services/api_service.dart';

class CalculatorScreen extends StatefulWidget {
  final MachineConfig machine;
  final VoidCallback? onPaymentCreated;
  const CalculatorScreen({super.key, required this.machine, this.onPaymentCreated});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';        // dígitos digitados (ex: "546" ou "546,5")
  bool _hasDecimal = false;
  int _decimalCount = 0;
  int _acumulado = 0;        // total acumulado em centavos
  String _expression = '';
  String _pay = 'pix';
  bool _loading = false;

  final _fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  // ── Lógica ────────────────────────────────────────────────────────
  double get _inputValor =>
      double.tryParse(_input.replaceAll(',', '.')) ?? 0.0;

  double get _total => _acumulado / 100 + _inputValor;

  String get _display {
    if (_input.isEmpty) return _fmt.format(0);
    if (_hasDecimal) {
      final parts = _input.split(',');
      final dec = parts.length > 1 ? parts[1] : '';
      if (dec.isEmpty) {
        final intVal = int.tryParse(parts[0]) ?? 0;
        return '${_fmt.format(intVal.toDouble()).replaceAll(',00', '')},';
      }
    }
    return _fmt.format(_inputValor);
  }

  void _digit(int d) => setState(() {
        if (_hasDecimal) {
          if (_decimalCount < 2) { _input += '$d'; _decimalCount++; }
        } else {
          if (_input.length < 8) {
            if (_input.isEmpty && d == 0) return;
            _input += '$d';
          }
        }
      });

  void _comma() => setState(() {
        if (_hasDecimal) return;
        if (_input.isEmpty) _input = '0';
        _input += ',';
        _hasDecimal = true;
        _decimalCount = 0;
      });

  void _back() => setState(() {
        if (_input.isEmpty) return;
        if (_input[_input.length - 1] == ',') {
          _hasDecimal = false; _decimalCount = 0;
        } else if (_hasDecimal) {
          _decimalCount--;
        }
        _input = _input.substring(0, _input.length - 1);
      });

  void _clear() => setState(() {
        _input = ''; _hasDecimal = false; _decimalCount = 0;
        _acumulado = 0; _expression = '';
      });

  void _plus() {
    if (_inputValor == 0) return;
    setState(() {
      _expression += '${_fmt.format(_inputValor)} + ';
      _acumulado += (_inputValor * 100).round();
      _input = ''; _hasDecimal = false; _decimalCount = 0;
    });
  }

  void _equal() {
    if (_total == 0) return;
    setState(() {
      final t = _total;
      _acumulado = 0; _expression = '';
      _input = t % 1 == 0
          ? t.toInt().toString()
          : t.toStringAsFixed(2).replaceAll('.', ',');
      _hasDecimal = _input.contains(',');
      _decimalCount = _hasDecimal ? _input.split(',')[1].length : 0;
    });
  }

  Future<void> _gerar() async {
    if (_total <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Digite um valor')));
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.criarPagamento(
        widget.machine.activationKey,
        valor: _total,
        formaPagamento: _pay,
        descricao: 'Cobrança via calculadora',
      );
      if (!mounted) return;
      _clear();
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✓ Pagamento criado! Acompanhe no Monitor.'),
            backgroundColor: Colors.green),
      );
      widget.onPaymentCreated?.call();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red));
    }
  }

  // ── UI ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Display
            _buildDisplay(primary),

            // Forma de pagamento
            _buildPaymentSelector(primary),

            // Teclado numérico
            Expanded(child: _buildKeypad(primary)),

            // Botão gerar
            _buildGerarBtn(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplay(Color primary) {
    return Container(
      width: double.infinity,
      color: primary,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(children: [
            const Icon(Icons.calculate, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            const Text('Calculadora',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17)),
          ]),
          const SizedBox(height: 12),
          if (_expression.isNotEmpty)
            Text(_expression,
                textAlign: TextAlign.right,
                style:
                    const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(_display,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold)),
          if (_acumulado > 0)
            Text('Total: ${_fmt.format(_total)}',
                textAlign: TextAlign.right,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPaymentSelector(Color primary) {
    final opts = [
      ('pix',    'PIX',     Icons.pix),
      ('credit', 'Crédito', Icons.credit_card),
      ('debit',  'Débito',  Icons.credit_card_outlined),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: opts.map((o) {
          final sel = _pay == o.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _pay = o.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? primary.withAlpha(25) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: sel ? primary : Colors.transparent,
                      width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(o.$3,
                        size: 22, color: sel ? primary : Colors.grey),
                    const SizedBox(height: 4),
                    Text(o.$2,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: sel ? primary : Colors.grey)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeypad(Color primary) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          Expanded(child: _numRow([7, 8, 9], primary, rightOp: '+')),
          const SizedBox(height: 6),
          Expanded(child: _numRow([4, 5, 6], primary)),
          const SizedBox(height: 6),
          Expanded(child: _numRow([1, 2, 3], primary)),
          const SizedBox(height: 6),
          Expanded(child: _numRow([null, 0, null], primary, comma: true, backspace: true)),
          const SizedBox(height: 6),
          _actionRow(primary),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _numRow(List<int?> nums, Color primary,
      {String? rightOp, bool comma = false, bool backspace = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primeira coluna: vírgula ou número ou vazio
        Expanded(
          child: comma
              ? _Key(',', Colors.white, Colors.black87, 22, _comma)
              : nums[0] != null
                  ? _Key('${nums[0]}', Colors.white, Colors.black87, 26,
                      () => _digit(nums[0]!))
                  : const SizedBox(),
        ),
        const SizedBox(width: 6),
        // Segunda coluna: sempre número
        Expanded(
          child: nums[1] != null
              ? _Key('${nums[1]}', Colors.white, Colors.black87, 26,
                  () => _digit(nums[1]!))
              : const SizedBox(),
        ),
        const SizedBox(width: 6),
        // Terceira coluna: backspace ou número ou vazio
        Expanded(
          child: backspace
              ? _Key('⌫', Colors.orange.shade50, Colors.orange, 22, _back)
              : nums[2] != null
                  ? _Key('${nums[2]}', Colors.white, Colors.black87, 26,
                      () => _digit(nums[2]!))
                  : const SizedBox(),
        ),
        const SizedBox(width: 6),
        // Quarta coluna: operador direito
        Expanded(
          child: rightOp != null
              ? _Key(rightOp, primary.withAlpha(25), primary, 26, _plus)
              : const SizedBox(),
        ),
      ],
    );
  }

  Widget _actionRow(Color primary) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(child: _Key('C', Colors.red.shade400, Colors.white, 22, _clear)),
          const SizedBox(width: 6),
          Expanded(
              flex: 2,
              child: _Key('=', Colors.green, Colors.white, 26, _equal)),
        ],
      ),
    );
  }

  Widget _buildGerarBtn() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: ElevatedButton.icon(
        onPressed: (_loading || _total <= 0) ? null : _gerar,
        icon: _loading
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send),
        label: Text(
          _total > 0 ? 'GERAR  ${_fmt.format(_total)}' : 'GERAR PAGAMENTO',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size.fromHeight(52),
        ),
      ),
    );
  }

  Widget _Key(String label, Color bg, Color fg, double size, VoidCallback onTap) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: size,
                  fontWeight: FontWeight.bold,
                  color: fg)),
        ),
      ),
    );
  }
}
