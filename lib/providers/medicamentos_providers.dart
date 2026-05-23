import 'package:flutter/material.dart';
import '../models/doacao_model.dart';
import '../services/firestore_service.dart';

class MedicamentosProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<DoacaoModel> _medicamentos = [];
  String _filtro = '';
  String _categoriaFiltro = 'Todos';

  List<DoacaoModel> get medicamentos {
    return _medicamentos.where((m) {
      final matchNome = m.nomeMedicamento
          .toLowerCase()
          .contains(_filtro.toLowerCase());
      final matchCat =
          _categoriaFiltro == 'Todos' || m.categoria == _categoriaFiltro;
      return matchNome && matchCat;
    }).toList();
  }

  String get categoriaFiltro => _categoriaFiltro;

  void iniciar() {
    _service.streamMedicamentos().listen((lista) {
      _medicamentos = lista;
      notifyListeners();
    });
  }

  void setFiltro(String valor) {
    _filtro = valor;
    notifyListeners();
  }

  void setCategoria(String cat) {
    _categoriaFiltro = cat;
    notifyListeners();
  }

  Future<void> adicionar(DoacaoModel doacao) async {
    await _service.adicionarMedicamento(doacao);
  }

  Future<void> eliminar(String id) async {
    await _service.eliminarMedicamento(id);
  }

  static const List<String> categorias = [
    'Todos',
    'Antibiótico',
    'Antipirético',
    'Vitamina',
    'Antidiabético',
    'Analgésico',
    'Anti-inflamatório',
    'Outro',
  ];
}