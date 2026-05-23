import 'package:cloud_firestore/cloud_firestore.dart';

class DoacaoModel {
  final String? id;
  final String nomeMedicamento;
  final DateTime validade;
  final int quantidade;
  final String categoria;
  final String doadorId;
  final String? doadorNome;

  DoacaoModel({
    this.id,
    required this.nomeMedicamento,
    required this.validade,
    required this.quantidade,
    required this.categoria,
    required this.doadorId,
    this.doadorNome,
  });

  factory DoacaoModel.fromMap(Map<String, dynamic> map, String id) {
    return DoacaoModel(
      id: id,
      nomeMedicamento: map['nome_medicamento'] ?? '',
      validade: (map['validade'] as Timestamp).toDate(),
      quantidade: map['quantidade'] ?? 0,
      categoria: map['categoria'] ?? '',
      doadorId: map['doador_id'] ?? '',
      doadorNome: map['doador_nome'],
    );
  }

  Map<String, dynamic> toMap() => {
        'nome_medicamento': nomeMedicamento,
        'validade': Timestamp.fromDate(validade),
        'quantidade': quantidade,
        'categoria': categoria,
        'doador_id': doadorId,
        'doador_nome': doadorNome,
        'criadoEm': FieldValue.serverTimestamp(),
      };

  bool get isExpirado => validade.isBefore(DateTime.now());
  bool get expiraEmBreve =>
      !isExpirado &&
      validade.isBefore(DateTime.now().add(const Duration(days: 30)));
}