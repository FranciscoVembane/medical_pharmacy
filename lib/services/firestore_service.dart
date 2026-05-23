import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doacao_model.dart';
import '../models/beneficiario_model.dart';
import '../models/tarefa_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Medicamentos ──────────────────────────────────────────

  Stream<List<DoacaoModel>> streamMedicamentos() {
    return _db
        .collection('doacoes')
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => DoacaoModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> adicionarMedicamento(DoacaoModel doacao) async {
    await _db.collection('doacoes').add(doacao.toMap());
  }

  Future<void> eliminarMedicamento(String id) async {
    await _db.collection('doacoes').doc(id).delete();
  }

  // ── Beneficiários ─────────────────────────────────────────

  Stream<List<BeneficiarioModel>> streamBeneficiarios() {
    return _db
        .collection('beneficiarios')
        .orderBy('nome')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BeneficiarioModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> adicionarBeneficiario(BeneficiarioModel b) async {
    await _db.collection('beneficiarios').add(b.toMap());
  }

  Future<void> eliminarBeneficiario(String id) async {
    await _db.collection('beneficiarios').doc(id).delete();
  }

  // ── Tarefas ───────────────────────────────────────────────

  Stream<List<TarefaModel>> streamTarefas() {
    return _db
        .collection('tarefas')
        .orderBy('data_prevista')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TarefaModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> criarTarefa(TarefaModel tarefa) async {
    await _db.collection('tarefas').add(tarefa.toMap());
  }

  Future<void> atualizarStatusTarefa(String id, TarefaStatus status) async {
    await _db
        .collection('tarefas')
        .doc(id)
        .update({'status': status.name});
  }
}