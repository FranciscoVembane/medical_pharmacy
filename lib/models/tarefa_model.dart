import 'package:cloud_firestore/cloud_firestore.dart';

enum TarefaStatus { pendente, emProgresso, concluida }

class TarefaModel {
  final String? id;
  final String descricao;
  final String medicamentoNome;
  final String beneficiarioNome;
  final String operadorNome;
  final String operadorId;
  final DateTime dataPrevista;
  final TarefaStatus status;

  TarefaModel({
    this.id,
    required this.descricao,
    required this.medicamentoNome,
    required this.beneficiarioNome,
    required this.operadorNome,
    required this.operadorId,
    required this.dataPrevista,
    this.status = TarefaStatus.pendente,
  });

  factory TarefaModel.fromMap(Map<String, dynamic> map, String id) {
    return TarefaModel(
      id: id,
      descricao: map['descricao'] ?? '',
      medicamentoNome: map['medicamento_nome'] ?? '',
      beneficiarioNome: map['beneficiario_nome'] ?? '',
      operadorNome: map['operador_nome'] ?? '',
      operadorId: map['operador_id'] ?? '',
      dataPrevista: (map['data_prevista'] as Timestamp).toDate(),
      status: TarefaStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TarefaStatus.pendente,
      ),
    );
  }

  Map<String, dynamic> toMap() => {
        'descricao': descricao,
        'medicamento_nome': medicamentoNome,
        'beneficiario_nome': beneficiarioNome,
        'operador_nome': operadorNome,
        'operador_id': operadorId,
        'data_prevista': Timestamp.fromDate(dataPrevista),
        'status': status.name,
        'criadoEm': FieldValue.serverTimestamp(),
      };

  TarefaModel copyWith({TarefaStatus? status}) => TarefaModel(
        id: id,
        descricao: descricao,
        medicamentoNome: medicamentoNome,
        beneficiarioNome: beneficiarioNome,
        operadorNome: operadorNome,
        operadorId: operadorId,
        dataPrevista: dataPrevista,
        status: status ?? this.status,
      );
}