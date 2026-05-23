import 'package:flutter/material.dart';
import '../models/beneficiario_model.dart';
import '../services/firestore_service.dart';

class BeneficiariosProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<BeneficiarioModel> _beneficiarios = [];
  String _filtro = '';

  List<BeneficiarioModel> get beneficiarios {
    if (_filtro.isEmpty) return _beneficiarios;
    return _beneficiarios
        .where((b) =>
            b.nome.toLowerCase().contains(_filtro.toLowerCase()) ||
            b.condicaoMedica.toLowerCase().contains(_filtro.toLowerCase()))
        .toList();
  }

  void iniciar() {
    _service.streamBeneficiarios().listen((lista) {
      _beneficiarios = lista;
      notifyListeners();
    });
  }

  void setFiltro(String valor) {
    _filtro = valor;
    notifyListeners();
  }

  Future<void> adicionar(BeneficiarioModel b) async {
    await _service.adicionarBeneficiario(b);
  }

  Future<void> eliminar(String id) async {
    await _service.eliminarBeneficiario(id);
  }
}