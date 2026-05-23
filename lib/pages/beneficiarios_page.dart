import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/beneficiarios_providers.dart';
import '../models/beneficiario_model.dart';

class BeneficiariosPage extends StatelessWidget {
  const BeneficiariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3498DB),
        title: const Text('Beneficiários',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) =>
                  context.read<BeneficiariosProvider>().setFiltro(v),
              decoration: InputDecoration(
                hintText: 'Pesquisar beneficiário...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Consumer<BeneficiariosProvider>(
              builder: (_, prov, __) {
                final lista = prov.beneficiarios;
                if (lista.isEmpty) {
                  return const Center(
                      child: Text('Nenhum beneficiário encontrado.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: lista.length,
                  itemBuilder: (_, i) =>
                      _BeneficiarioCard(beneficiario: lista[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3498DB),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _mostrarFormulario(context),
      ),
    );
  }

  void _mostrarFormulario(BuildContext context) {
    final nomeCtrl = TextEditingController();
    final idadeCtrl = TextEditingController();
    final contactoCtrl = TextEditingController();
    final enderecoCtrl = TextEditingController();
    final condicaoCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Cadastrar Beneficiário',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nomeCtrl,
                decoration: InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: idadeCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Idade',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactoCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Contacto',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: enderecoCtrl,
                decoration: InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: condicaoCtrl,
                decoration: InputDecoration(
                  labelText: 'Condição médica',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB)),
                onPressed: () async {
                  if (nomeCtrl.text.isEmpty ||
                      condicaoCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Preencha os campos obrigatórios.')));
                    return;
                  }
                  await context
                      .read<BeneficiariosProvider>()
                      .adicionar(BeneficiarioModel(
                        nome: nomeCtrl.text.trim(),
                        idade: int.tryParse(idadeCtrl.text) ?? 0,
                        contacto: contactoCtrl.text.trim(),
                        endereco: enderecoCtrl.text.trim(),
                        condicaoMedica: condicaoCtrl.text.trim(),
                      ));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Beneficiário cadastrado!')));
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

class _BeneficiarioCard extends StatelessWidget {
  final BeneficiarioModel beneficiario;
  const _BeneficiarioCard({required this.beneficiario});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFE6F1FB),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Color(0xFF3498DB)),
        ),
        title: Text(beneficiario.nome,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${beneficiario.idade} anos · ${beneficiario.contacto}\n${beneficiario.condicaoMedica}'),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F1FB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Activo',
              style: TextStyle(
                  color: Color(0xFF3498DB),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ),
        isThreeLine: true,
      ),
    );
  }
}