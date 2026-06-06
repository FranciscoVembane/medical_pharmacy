import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/tarefas_providers.dart';
import '../providers/medicamentos_providers.dart';
import '../providers/beneficiarios_providers.dart';
import '../models/tarefa_model.dart';

class TarefasPage extends StatelessWidget {
  const TarefasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF39C12),
        title: const Text('Tarefas',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<TarefasProvider>(
        builder: (_, prov, __) {
          final tarefas = prov.tarefas;
          if (tarefas.isEmpty) {
            return const Center(
                child: Text('Nenhuma tarefa encontrada.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tarefas.length,
            itemBuilder: (_, i) => _TarefaCard(tarefa: tarefas[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF39C12),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _mostrarFormulario(context),
      ),
    );
  }

  void _mostrarFormulario(BuildContext context) {
    final descCtrl = TextEditingController();
    final operadorCtrl = TextEditingController();
    DateTime? dataPrevista;
    String? medicamentoNome;
    String? beneficiarioNome;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Criar Tarefa',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: descCtrl,
                  decoration: InputDecoration(
                    labelText: 'Descrição da tarefa',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                // Seleccionar medicamento
                Consumer<MedicamentosProvider>(
                  builder: (_, mProv, __) => DropdownButtonFormField<String>(
                    initialValue: medicamentoNome,
                    decoration: InputDecoration(
                      labelText: 'Medicamento',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    items: mProv.medicamentos
                        .map((m) => DropdownMenuItem(
                            value: m.nomeMedicamento,
                            child: Text(m.nomeMedicamento)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => medicamentoNome = v),
                  ),
                ),
                const SizedBox(height: 12),
                // Seleccionar beneficiário
                Consumer<BeneficiariosProvider>(
                  builder: (_, bProv, __) =>
                      DropdownButtonFormField<String>(
                    initialValue: beneficiarioNome,
                    decoration: InputDecoration(
                      labelText: 'Beneficiário',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    items: bProv.beneficiarios
                        .map((b) => DropdownMenuItem(
                            value: b.nome, child: Text(b.nome)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => beneficiarioNome = v),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: operadorCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nome do operador',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(dataPrevista == null
                      ? 'Seleccionar data prevista'
                      : DateFormat('dd/MM/yyyy').format(dataPrevista!)),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (d != null) setState(() => dataPrevista = d);
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF39C12)),
                  onPressed: () async {
                    // Validações
                    if (descCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Por favor insira a descrição da tarefa.')));
                      return;
                    }

                    if (descCtrl.text.trim().length < 5) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('A descrição deve ter pelo menos 5 caracteres.')));
                      return;
                    }

                    if (medicamentoNome == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Por favor seleccione um medicamento.')));
                      return;
                    }

                    if (beneficiarioNome == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Por favor seleccione um beneficiário.')));
                      return;
                    }

                    if (operadorCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Por favor insira o nome do operador.')));
                      return;
                    }

                    if (dataPrevista == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Por favor seleccione a data prevista.')));
                      return;
                    }

                    if (dataPrevista!.isBefore(DateTime.now())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('A data prevista não pode ser no passado.')));
                      return;
                    }

                    await context.read<TarefasProvider>().criar(
                      TarefaModel(
                        descricao: descCtrl.text.trim(),
                        medicamentoNome: medicamentoNome!,
                        beneficiarioNome: beneficiarioNome!,
                        operadorNome: operadorCtrl.text.trim(),
                        operadorId: '',
                        dataPrevista: dataPrevista!,
                      ),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tarefa criada!')));
                  },
                  child: const Text('Guardar',
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TarefaCard extends StatelessWidget {
  final TarefaModel tarefa;
  const _TarefaCard({required this.tarefa});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;

    switch (tarefa.status) {
      case TarefaStatus.pendente:
        statusColor = Colors.grey;
        statusLabel = 'Pendente';
        break;
      case TarefaStatus.emProgresso:
        statusColor = const Color(0xFFF39C12);
        statusLabel = 'Em progresso';
        break;
      case TarefaStatus.concluida:
        statusColor = const Color(0xFF2ECC71);
        statusLabel = 'Concluída';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(tarefa.descricao,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('💊 ${tarefa.medicamentoNome}',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text('👤 ${tarefa.beneficiarioNome}',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text('🧑‍⚕️ Operador: ${tarefa.operadorNome}',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text(
                '📅 ${DateFormat('dd/MM/yyyy').format(tarefa.dataPrevista)}',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            if (tarefa.status != TarefaStatus.concluida) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (tarefa.status == TarefaStatus.pendente)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context
                            .read<TarefasProvider>()
                            .atualizarStatus(
                                tarefa.id!, TarefaStatus.emProgresso),
                        child: const Text('Iniciar'),
                      ),
                    ),
                  if (tarefa.status == TarefaStatus.emProgresso) ...[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71)),
                        onPressed: () => context
                            .read<TarefasProvider>()
                            .atualizarStatus(
                                tarefa.id!, TarefaStatus.concluida),
                        child: const Text('Concluir',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}