import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/machine_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

class ApiService {
  static Future<MachineConfig> findByCodigo(String codigo) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/activation/machine?codigo=$codigo');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    final body = jsonDecode(res.body);
    if (res.statusCode == 200) return MachineConfig.fromJson(body);
    throw ApiException(res.statusCode, body['message'] ?? 'Máquina não encontrada');
  }

  static Future<MachineConfig> findById(int id) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/activation/machine/$id');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    final body = jsonDecode(res.body);
    if (res.statusCode == 200) return MachineConfig.fromJson(body);
    throw ApiException(res.statusCode, body['message'] ?? 'Máquina não encontrada');
  }

  static Future<List<Pagamento>> listPagamentos(
    String activationKey, {
    String? status,
  }) async {
    final params = status != null ? '?status=$status' : '';
    final uri = Uri.parse('${AppConfig.baseUrl}/monitor/pagamentos$params');
    final res = await http.get(uri, headers: _headers(activationKey))
        .timeout(const Duration(seconds: 10));
    final body = jsonDecode(res.body);
    if (res.statusCode == 200) {
      final data = body['data'] as List? ?? (body is List ? body : []);
      return data.map((e) => Pagamento.fromJson(e)).toList();
    }
    throw ApiException(res.statusCode, body['message'] ?? 'Erro ao listar pagamentos');
  }

  static Future<Pagamento> criarPagamento(
    String activationKey, {
    required double valor,
    required String formaPagamento,
    String descricao = 'Pagamento via calculadora',
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/monitor/pagamentos');
    final res = await http.post(
      uri,
      headers: _headers(activationKey),
      body: jsonEncode({
        'valor': valor,
        'forma_pagamento': formaPagamento,
        'descricao': descricao,
      }),
    ).timeout(const Duration(seconds: 15));
    final body = jsonDecode(res.body);
    if (res.statusCode == 201) return Pagamento.fromJson(body);
    throw ApiException(res.statusCode, body['message'] ?? 'Erro ao criar pagamento');
  }

  static Future<Pagamento> atualizarStatus(
    String activationKey,
    int pagamentoId,
    String status,
  ) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/monitor/pagamentos/$pagamentoId/status');
    final res = await http.put(
      uri,
      headers: _headers(activationKey),
      body: jsonEncode({'status': status}),
    ).timeout(const Duration(seconds: 15));
    final body = jsonDecode(res.body);
    if (res.statusCode == 200) return Pagamento.fromJson(body);
    throw ApiException(res.statusCode, body['message'] ?? 'Erro ao atualizar status');
  }

  static Map<String, String> _headers(String activationKey) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Activation-Key': activationKey,
      };
}
