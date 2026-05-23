import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/medicamentos_providers.dart';
import '../providers/beneficiarios_providers.dart';
import '../providers/tarefas_providers.dart';
import 'login_page.dart';
import 'medicamentos_pages.dart';
import 'beneficiarios_page.dart';
import 'tarefas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String userName = '';
  String userTipo = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    context.read<MedicamentosProvider>().iniciar();
    context.read<BeneficiariosProvider>().iniciar();
    context.read<TarefasProvider>().iniciar();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            userName = doc.get('name') ?? '';
            userTipo = doc.get('tipo') ?? 'doador';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2ECC71),
        title: _isLoading
            ? const Text('Medical Pharmacy')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Medical Pharmacy',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                  Text('Olá, $userName',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white70)),
                ],
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estatísticas
                  Consumer3<MedicamentosProvider, BeneficiariosProvider,
                      TarefasProvider>(
                    builder: (_, meds, benef, tarefas, __) => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _statCard('Medicamentos',
                            meds.medicamentos.length.toString(),
                            Icons.medication, const Color(0xFF2ECC71)),
                        _statCard('Beneficiários',
                            benef.beneficiarios.length.toString(),
                            Icons.people, const Color(0xFF3498DB)),
                        _statCard('Tarefas Activas',
                            tarefas.tarefasPendentes.length.toString(),
                            Icons.task, const Color(0xFFF39C12)),
                        _statCard('Concluídas',
                            tarefas.tarefasConcluidas.length.toString(),
                            Icons.check_circle, const Color(0xFF9B59B6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Módulos',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _menuItem(
                    icon: Icons.medication,
                    label: 'Medicamentos',
                    sub: 'Gerir doações e stock',
                    color: const Color(0xFF2ECC71),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const MedicamentosPage())),
                  ),
                  _menuItem(
                    icon: Icons.people,
                    label: 'Beneficiários',
                    sub: 'Gerir beneficiários',
                    color: const Color(0xFF3498DB),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const BeneficiariosPage())),
                  ),
                  _menuItem(
                    icon: Icons.task,
                    label: 'Tarefas',
                    sub: 'Atribuir e acompanhar tarefas',
                    color: const Color(0xFFF39C12),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const TarefasPage())),
                  ),
                ],
              ),
            ),
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
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
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
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration:
              // ignore: deprecated_member_use
              BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(sub,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}