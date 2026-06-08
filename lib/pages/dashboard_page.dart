import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _firestore = FirebaseFirestore.instance;

  int totalMedicamentos = 0;
  int medicamentosValidos = 0;
  int medicamentosExpirados = 0;
  int medicamentosExpiraEmBreve = 0;
  int totalBeneficiarios = 0;
  int tarefasPendentes = 0;
  int tarefasEmProgresso = 0;
  int tarefasConcluidas = 0;
  int totalDoacoes = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarEstatisticas();
  }

  Future<void> _carregarEstatisticas() async {
    try {
      // Medicamentos
      final medicamentosSnap =
      await _firestore.collection('doacoes').get();
      final agora = DateTime.now();
      int validos = 0, expirados = 0, expiraEmBreve = 0;

      for (var doc in medicamentosSnap.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        final validade =
        (data['validade'] as dynamic).toDate() as DateTime;
        final diff = validade.difference(agora).inDays;
        if (diff < 0) {
          expirados++;
        } else if (diff < 30) {
          expiraEmBreve++;
        } else {
          validos++;
        }
      }

      // Beneficiários
      final beneficiariosSnap =
      await _firestore.collection('beneficiarios').get();

      // Tarefas
      final tarefasSnap = await _firestore.collection('tarefas').get();
      int pendentes = 0, emProgresso = 0, concluidas = 0;
      for (var doc in tarefasSnap.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        final status = data['status'] ?? 'pendente';
        if (status == 'pendente') pendentes++;
        if (status == 'emProgresso') emProgresso++;
        if (status == 'concluida') concluidas++;
      }

      setState(() {
        totalMedicamentos = medicamentosSnap.docs.length;
        medicamentosValidos = validos;
        medicamentosExpirados = expirados;
        medicamentosExpiraEmBreve = expiraEmBreve;
        totalBeneficiarios = beneficiariosSnap.docs.length;
        tarefasPendentes = pendentes;
        tarefasEmProgresso = emProgresso;
        tarefasConcluidas = concluidas;
        totalDoacoes = medicamentosSnap.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2ECC71),
        title: const Text('Dashboard',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => _isLoading = true);
              _carregarEstatisticas();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _carregarEstatisticas,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumo geral
              _sectionTitle('Resumo Geral'),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _statCard('Total Medicamentos',
                      totalMedicamentos.toString(),
                      Icons.medication, const Color(0xFF2ECC71)),
                  _statCard('Beneficiários',
                      totalBeneficiarios.toString(),
                      Icons.people, const Color(0xFF3498DB)),
                  _statCard('Total Doações',
                      totalDoacoes.toString(),
                      Icons.volunteer_activism,
                      const Color(0xFF9B59B6)),
                  _statCard('Tarefas Concluídas',
                      tarefasConcluidas.toString(),
                      Icons.check_circle,
                      const Color(0xFF27AE60)),
                ],
              ),

              const SizedBox(height: 24),

              // Estado dos medicamentos
              _sectionTitle('Estado dos Medicamentos'),
              _barraProgresso(
                label: 'Válidos',
                valor: medicamentosValidos,
                total: totalMedicamentos,
                color: const Color(0xFF2ECC71),
              ),
              _barraProgresso(
                label: 'Expira em breve',
                valor: medicamentosExpiraEmBreve,
                total: totalMedicamentos,
                color: const Color(0xFFF39C12),
              ),
              _barraProgresso(
                label: 'Expirados',
                valor: medicamentosExpirados,
                total: totalMedicamentos,
                color: const Color(0xFFE74C3C),
              ),

              const SizedBox(height: 24),

              // Estado das tarefas
              _sectionTitle('Estado das Tarefas'),
              _barraProgresso(
                label: 'Pendentes',
                valor: tarefasPendentes,
                total: tarefasPendentes +
                    tarefasEmProgresso +
                    tarefasConcluidas,
                color: Colors.grey,
              ),
              _barraProgresso(
                label: 'Em progresso',
                valor: tarefasEmProgresso,
                total: tarefasPendentes +
                    tarefasEmProgresso +
                    tarefasConcluidas,
                color: const Color(0xFFF39C12),
              ),
              _barraProgresso(
                label: 'Concluídas',
                valor: tarefasConcluidas,
                total: tarefasPendentes +
                    tarefasEmProgresso +
                    tarefasConcluidas,
                color: const Color(0xFF2ECC71),
              ),

              const SizedBox(height: 24),

              // Taxa de conclusão
              _sectionTitle('Taxa de Conclusão de Tarefas'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _taxaConclusao(),
                      style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2ECC71)),
                    ),
                    const Text('das tarefas concluídas',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _taxaConclusaoValor(),
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2ECC71)),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _taxaConclusao() {
    final total =
        tarefasPendentes + tarefasEmProgresso + tarefasConcluidas;
    if (total == 0) return '0%';
    return '${((tarefasConcluidas / total) * 100).toStringAsFixed(0)}%';
  }

  double _taxaConclusaoValor() {
    final total =
        tarefasPendentes + tarefasEmProgresso + tarefasConcluidas;
    if (total == 0) return 0;
    return tarefasConcluidas / total;
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _statCard(
      String label, String valor, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(valor,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              textAlign: TextAlign.center,
              style:
              const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _barraProgresso({
    required String label,
    required int valor,
    required int total,
    required Color color,
  }) {
    final percentagem = total == 0 ? 0.0 : valor / total;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
              Text('$valor (${ (percentagem * 100).toStringAsFixed(0)}%)',
                  style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentagem,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}