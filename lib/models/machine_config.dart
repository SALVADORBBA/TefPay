class MachineConfig {
  final int id;
  final String name;
  final String? serialNumber;
  final String activationKey;
  final bool active;
  final PartnerConfig partner;
  final BeneficiaryConfig? beneficiary;
  final SystemUnitConfig? systemUnit;

  const MachineConfig({
    required this.id,
    required this.name,
    this.serialNumber,
    required this.activationKey,
    required this.active,
    required this.partner,
    this.beneficiary,
    this.systemUnit,
  });

  factory MachineConfig.fromJson(Map<String, dynamic> json) => MachineConfig(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        serialNumber: json['serial_number'],
        activationKey: json['activation_key'] ?? '',
        active: json['active'] == true || json['active'] == 1,
        partner: PartnerConfig.fromJson(json['partner'] ?? {}),
        beneficiary: json['beneficiary'] != null
            ? BeneficiaryConfig.fromJson(json['beneficiary'])
            : null,
        systemUnit: json['system_unit'] != null
            ? SystemUnitConfig.fromJson(json['system_unit'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'serial_number': serialNumber,
        'activation_key': activationKey,
        'active': active,
        'partner': partner.toJson(),
        'beneficiary': beneficiary?.toJson(),
        'system_unit': systemUnit?.toJson(),
      };
}

class PartnerConfig {
  final int id;
  final String name;
  final String? logoUrl;
  final String? logoHomeUrl;
  final String? primaryColor;
  final String? secondaryColor;
  final String? accentColor;
  final String? document;
  final String? phone;
  final String? email;
  final String? domain;

  const PartnerConfig({
    required this.id,
    required this.name,
    this.logoUrl,
    this.logoHomeUrl,
    this.primaryColor,
    this.secondaryColor,
    this.accentColor,
    this.document,
    this.phone,
    this.email,
    this.domain,
  });

  factory PartnerConfig.fromJson(Map<String, dynamic> json) {
    final cfg = json['app_config'] as Map<String, dynamic>?;
    return PartnerConfig(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logoUrl: cfg?['logo_url'] ?? json['logo_url'],
      logoHomeUrl: cfg?['logo_home_url'] ?? json['logo_home_url'],
      primaryColor: cfg?['primary_color'] ?? json['primary_color'],
      secondaryColor: cfg?['secondary_color'] ?? json['secondary_color'],
      accentColor: cfg?['accent_color'] ?? json['accent_color'],
      document: json['formatted_document'] ?? json['document'],
      phone: json['formatted_contact_phone'] ?? json['contact_phone'],
      email: json['contact_email'] ?? json['email'],
      domain: json['domain'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logo_url': logoUrl,
        'logo_home_url': logoHomeUrl,
        'primary_color': primaryColor,
        'secondary_color': secondaryColor,
        'accent_color': accentColor,
        'document': document,
        'phone': phone,
        'email': email,
        'domain': domain,
      };
}

class BeneficiaryConfig {
  final int id;
  final String name;
  final String? document;
  final String? phone;
  final String? email;
  final String? type;
  final String? logradouro;
  final String? numero;
  final String? bairro;
  final String? cidade;
  final String? estado;

  const BeneficiaryConfig({
    required this.id,
    required this.name,
    this.document,
    this.phone,
    this.email,
    this.type,
    this.logradouro,
    this.numero,
    this.bairro,
    this.cidade,
    this.estado,
  });

  factory BeneficiaryConfig.fromJson(Map<String, dynamic> json) =>
      BeneficiaryConfig(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        document: json['document'],
        phone: json['phone'],
        email: json['email'],
        type: json['type'],
        logradouro: json['logradouro'],
        numero: json['numero'],
        bairro: json['bairro'],
        cidade: json['cidade'],
        estado: json['estado'],
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'document': document, 'phone': phone,
        'email': email, 'type': type, 'logradouro': logradouro,
        'numero': numero, 'bairro': bairro, 'cidade': cidade, 'estado': estado,
      };
}

class SystemUnitConfig {
  final int id;
  final String name;
  final String? document;
  final String? phone;
  final String? cidade;
  final String? estado;

  const SystemUnitConfig({
    required this.id,
    required this.name,
    this.document,
    this.phone,
    this.cidade,
    this.estado,
  });

  factory SystemUnitConfig.fromJson(Map<String, dynamic> json) =>
      SystemUnitConfig(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        document: json['document'],
        phone: json['phone'],
        cidade: json['cidade'],
        estado: json['estado'],
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'document': document,
        'phone': phone, 'cidade': cidade, 'estado': estado,
      };
}

class Pagamento {
  final int id;
  final int amount;
  final String paymentType;
  final String status;
  final String? descricao;
  final String? nsu;
  final String? brand;
  final String? cardNumber;
  final String createdAt;

  const Pagamento({
    required this.id,
    required this.amount,
    required this.paymentType,
    required this.status,
    this.descricao,
    this.nsu,
    this.brand,
    this.cardNumber,
    required this.createdAt,
  });

  double get valorReais => amount / 100;

  String get statusLabel {
    switch (status) {
      case 'approved': return 'Aprovado';
      case 'pending':  return 'Pendente';
      case 'declined': return 'Recusado';
      case 'cancelled':return 'Cancelado';
      case 'error':    return 'Erro';
      default:         return status;
    }
  }

  String get paymentTypeLabel {
    switch (paymentType) {
      case 'credit':  return 'Crédito';
      case 'debit':   return 'Débito';
      case 'pix':     return 'PIX';
      case 'cash':    return 'Dinheiro';
      case 'voucher': return 'Voucher';
      default:        return paymentType;
    }
  }

  factory Pagamento.fromJson(Map<String, dynamic> json) => Pagamento(
        id: json['id'],
        amount: json['amount'] ?? 0,
        paymentType: json['payment_type'] ?? '',
        status: json['status'] ?? 'pending',
        descricao: json['descricao'],
        nsu: json['nsu'],
        brand: json['brand'],
        cardNumber: json['card_number'],
        createdAt: json['created_at'] ?? '',
      );
}
