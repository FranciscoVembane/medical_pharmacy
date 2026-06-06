import 'package:cloud_firestore/cloud_firestore.dart';
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
                  itemBuilder: (_, i) => _BeneficiarioCard(
                    beneficiario: lista[i],
                    userTipo: context.read<BeneficiariosProvider>().userTipo,
                  ),
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
                  // Validações
                  if (nomeCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Por favor insira o nome do beneficiário.')));
                    return;
                  }

                  if (nomeCtrl.text.trim().length < 3) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('O nome deve ter pelo menos 3 caracteres.')));
                    return;
                  }

                  if (idadeCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor insira a idade.')));
                    return;
                  }

                  final idade = int.tryParse(idadeCtrl.text.trim());
                  if (idade == null || idade <= 0 || idade > 120) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Insira uma idade válida (1-120).')));
                    return;
                  }

                  if (contactoCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor insira o contacto.')));
                    return;
                  }

                  if (contactoCtrl.text.trim().length < 9) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('O contacto deve ter pelo menos 9 dígitos.')));
                    return;
                  }

                  if (enderecoCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor insira o endereço.')));
                    return;
                  }

                  if (condicaoCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Por favor insira a condição médica.')));
                    return;
                  }

                  await context
                      .read<BeneficiariosProvider>()
                      .adicionar(BeneficiarioModel(
                    nome: nomeCtrl.text.trim(),
                    idade: idade,
                    contacto: contactoCtrl.text.trim(),
                    endereco: enderecoCtrl.text.trim(),
                    condicaoMedica: condicaoCtrl.text.trim(),
                  ));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Beneficiário cadastrado!')));
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
  final String userTipo;
  const _BeneficiarioCard(
      {required this.beneficiario, required this.userTipo});

  @override
  Widget build(BuildContext context) {
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
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F1FB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person,
                      color: Color(0xFF3498DB)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(beneficiario.nome,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                      Text(
                          '${beneficiario.idade} anos · ${beneficiario.contacto}',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                      Text(beneficiario.condicaoMedica,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
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
              ],
            ),
            // Botões admin e operador
            if (userTipo == 'admin' || userTipo == 'operador')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit_outlined,
                        size: 16, color: Color(0xFF3498DB)),
                    label: const Text('Editar',
                        style: TextStyle(
                            color: Color(0xFF3498DB), fontSize: 12)),
                    onPressed: () => _mostrarEdicao(context),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline,
                        size: 16, color: Colors.red),
                    label: const Text('Eliminar',
                        style:
                        TextStyle(color: Colors.red, fontSize: 12)),
                    onPressed: () => _confirmarEliminacao(context),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarEdicao(BuildContext context) {
    final nomeCtrl =
    TextEditingController(text: beneficiario.nome);
    final idadeCtrl =
    TextEditingController(text: beneficiario.idade.toString());
    final contactoCtrl =
    TextEditingController(text: beneficiario.contacto);
    final enderecoCtrl =
    TextEditingController(text: beneficiario.endereco);
    final condicaoCtrl =
    TextEditingController(text: beneficiario.condicaoMedica);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Editar Beneficiário',
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
                  if (nomeCtrl.text.trim().isEmpty ||
                      condicaoCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Preencha os campos obrigatórios.')));
                    return;
                  }
                  await FirebaseFirestore.instance
                      .collection('beneficiarios')
                      .doc(beneficiario.id)
                      .update({
                    'nome': nomeCtrl.text.trim(),
                    'idade':
                    int.tryParse(idadeCtrl.text.trim()) ??
                        beneficiario.idade,
                    'contacto': contactoCtrl.text.trim(),
                    'endereco': enderecoCtrl.text.trim(),
                    'condicao_medica': condicaoCtrl.text.trim(),
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Beneficiário actualizado!')));
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

  void _confirmarEliminacao(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar beneficiário'),
        content: Text(
            'Tens a certeza que queres eliminar "${beneficiario.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await context
          .read<BeneficiariosProvider>()
          .eliminar(beneficiario.id!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Beneficiário eliminado!')));
    }
  }
}