import 'package:cloud_firestore/cloud_firestore.dart';

class BeneficiarioModel {
  final String? id;
  final String nome;
  final int idade;
  final String contacto;
  final String endereco;
  final String condicaoMedica;

  BeneficiarioModel({
    this.id,
    required this.nome,
    required this.idade,
    required this.contacto,
    required this.endereco,
    required this.condicaoMedica,
  });

  factory BeneficiarioModel.fromMap(Map<String, dynamic> map, String id) {
    return BeneficiarioModel(
      id: id,
      nome: map['nome'] ?? '',
      idade: map['idade'] ?? 0,
      contacto: map['contacto'] ?? '',
      endereco: map['endereco'] ?? '',
      condicaoMedica: map['condicao_medica'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'idade': idade,
        'contacto': contacto,
        'endereco': endereco,
        'condicao_medica': condicaoMedica,
        'criadoEm': FieldValue.serverTimestamp(),
      };
}