import 'package:flutter/material.dart';
import '../models/tarefa_model.dart';
import '../services/firestore_service.dart';

class TarefasProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<TarefaModel> _tarefas = [];

  List<TarefaModel> get tarefas => _tarefas;

  List<TarefaModel> get tarefasPendentes =>
      _tarefas.where((t) => t.status == TarefaStatus.pendente).toList();

  List<TarefaModel> get tarefasEmProgresso =>
      _tarefas.where((t) => t.status == TarefaStatus.emProgresso).toList();

  List<TarefaModel> get tarefasConcluidas =>
      _tarefas.where((t) => t.status == TarefaStatus.concluida).toList();

  void iniciar() {
    _service.streamTarefas().listen((lista) {
      _tarefas = lista;
      notifyListeners();
    });
  }

  Future<void> criar(TarefaModel tarefa) async {
    await _service.criarTarefa(tarefa);
  }

  Future<void> atualizarStatus(String id, TarefaStatus status) async {
    await _service.atualizarStatusTarefa(id, status);
  }
}