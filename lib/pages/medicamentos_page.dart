import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../providers/medicamentos_providers.dart';
import '../models/doacao_model.dart';

class MedicamentosPage extends StatelessWidget {
  final String userTipo;
  const MedicamentosPage({super.key, required this.userTipo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2ECC71),
        title: const Text('Medicamentos',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) =>
                  context.read<MedicamentosProvider>().setFiltro(v),
              decoration: InputDecoration(
                hintText: 'Pesquisar medicamento...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // Filtro por categoria
          Consumer<MedicamentosProvider>(
            builder: (_, prov, __) => SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: MedicamentosProvider.categorias.length,
                itemBuilder: (_, i) {
                  final cat = MedicamentosProvider.categorias[i];
                  final selected = prov.categoriaFiltro == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (_) => prov.setCategoria(cat),
                      selectedColor: const Color(0xFF2ECC71),
                      labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Lista
          Expanded(
            child: Consumer<MedicamentosProvider>(
              builder: (_, prov, __) {
                final lista = prov.medicamentos;
                if (lista.isEmpty) {
                  return const Center(
                      child: Text('Nenhum medicamento encontrado.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: lista.length,
                  itemBuilder: (_, i) => _MedicamentoCard(med: lista[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2ECC71),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _mostrarFormulario(context),
      ),
    );
  }

  void _mostrarFormulario(BuildContext context) {
    final nomeCtrl = TextEditingController();
    final qtdCtrl = TextEditingController();
    String categoria = 'Antibiótico';
    DateTime? validade;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Registar Medicamento',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nomeCtrl,
                decoration: InputDecoration(
                  labelText: 'Nome do medicamento',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtdCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: categoria,
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                items: MedicamentosProvider.categorias
                    .where((c) => c != 'Todos')
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => categoria = v!),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(validade == null
                    ? 'Seleccionar validade'
                    : DateFormat('dd/MM/yyyy').format(validade!)),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (d != null) setState(() => validade = d);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71)),
                onPressed: () async {
                  if (nomeCtrl.text.isEmpty ||
                      qtdCtrl.text.isEmpty ||
                      validade == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Preencha todos os campos.')));
                    return;
                  }
                  final user = FirebaseAuth.instance.currentUser;
                  await context.read<MedicamentosProvider>().adicionar(
                        DoacaoModel(
                          nomeMedicamento: nomeCtrl.text.trim(),
                          quantidade: int.parse(qtdCtrl.text.trim()),
                          categoria: categoria,
                          validade: validade!,
                          doadorId: user?.uid ?? '',
                          doadorNome: user?.email ?? '',
                        ),
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Medicamento registado!')));
                },
                child: const Text('Guardar',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicamentoCard extends StatelessWidget {
  final DoacaoModel med;
  const _MedicamentoCard({required this.med});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String badgeLabel;

    if (med.isExpirado) {
      badgeColor = Colors.red;
      badgeLabel = 'Expirado';
    } else if (med.expiraEmBreve) {
      badgeColor = Colors.orange;
      badgeLabel = 'Expira em breve';
    } else {
      badgeColor = const Color(0xFF2ECC71);
      badgeLabel = 'Válido';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F8F0),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.medication,
              color: Color(0xFF2ECC71)),
        ),
        title: Text(med.nomeMedicamento,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${med.categoria} · Qtd: ${med.quantidade}\nValidade: ${DateFormat('dd/MM/yyyy').format(med.validade)}'),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(badgeLabel,
              style: TextStyle(
                  color: badgeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ),
        isThreeLine: true,
      ),
    );
  }
}