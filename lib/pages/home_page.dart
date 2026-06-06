import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/medicamentos_providers.dart';
import '../providers/beneficiarios_providers.dart';
import '../providers/tarefas_providers.dart';
import 'login_page.dart';
import 'medicamentos_page.dart';
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
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _verificarConectividade();
    context.read<MedicamentosProvider>().userTipo = userTipo;
    context.read<MedicamentosProvider>().iniciar();
    context.read<BeneficiariosProvider>().userTipo = userTipo;
    context.read<BeneficiariosProvider>().iniciar();
    context.read<TarefasProvider>().iniciar();
  }

  void _verificarConectividade() {
    Connectivity().onConnectivityChanged.listen((result) {
      var doc;
      final data = doc.data() as Map<String, dynamic>;
      final nome = data['name'] ?? '';
      final tipo = data['tipo'] ?? 'doador';

      context.read<MedicamentosProvider>().userTipo = tipo;
      context.read<BeneficiariosProvider>().userTipo = tipo;

      setState(() {
        userName = nome;
        userTipo = tipo;
        _isLoading = false;
      });
    });
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final nome = data['name'] ?? '';
          final tipo = data['tipo'] ?? 'doador';

          context.read<MedicamentosProvider>().userTipo = tipo;
          context.read<BeneficiariosProvider>().userTipo = tipo;

          setState(() {
            userName = nome;
            userTipo = tipo;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Erro: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Color get _perfilCor {
    switch (userTipo) {
      case 'admin':
        return const Color(0xFFE74C3C);
      case 'operador':
        return const Color(0xFF3498DB);
      default:
        return const Color(0xFF2ECC71);
    }
  }

  String get _perfilLabel {
    switch (userTipo) {
      case 'admin':
        return 'Administrador';
      case 'operador':
        return 'Operador';
      default:
        return 'Doador';
    }
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
          if (!_isLoading)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _perfilCor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_perfilLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner offline
          if (_isOffline)
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF8E1),
              padding: const EdgeInsets.symmetric(
                  vertical: 6, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off,
                      size: 14, color: Color(0xFFF39C12)),
                  SizedBox(width: 6),
                  Text(
                    'Sem ligação — a usar dados em cache',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFF39C12),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          // Resto do body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (userTipo == 'admin' || userTipo == 'operador')
                    Consumer3<MedicamentosProvider,
                        BeneficiariosProvider, TarefasProvider>(
                      builder: (_, meds, benef, tarefas, __) =>
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.5,
                            children: [
                              _statCard(
                                  'Medicamentos',
                                  meds.medicamentos.length.toString(),
                                  Icons.medication,
                                  const Color(0xFF2ECC71)),
                              _statCard(
                                  'Beneficiários',
                                  benef.beneficiarios.length.toString(),
                                  Icons.people,
                                  const Color(0xFF3498DB)),
                              _statCard(
                                  'Tarefas Activas',
                                  tarefas.tarefasPendentes.length.toString(),
                                  Icons.task,
                                  const Color(0xFFF39C12)),
                              _statCard(
                                  'Concluídas',
                                  tarefas.tarefasConcluidas.length.toString(),
                                  Icons.check_circle,
                                  const Color(0xFF9B59B6)),
                            ],
                          ),
                    ),
                  const SizedBox(height: 24),
                  const Text('Módulos',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _menuItem(
                    icon: Icons.medication,
                    label: 'Medicamentos',
                    sub: userTipo == 'doador'
                        ? 'Registar doações'
                        : 'Gerir medicamentos',
                    color: const Color(0xFF2ECC71),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MedicamentosPage(
                                userTipo: userTipo))),
                  ),
                  if (userTipo == 'admin' || userTipo == 'operador')
                    _menuItem(
                      icon: Icons.people,
                      label: 'Beneficiários',
                      sub: 'Gerir beneficiários',
                      color: const Color(0xFF3498DB),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              const BeneficiariosPage())),
                    ),
                  if (userTipo == 'admin' || userTipo == 'operador')
                    _menuItem(
                      icon: Icons.task,
                      label: 'Tarefas',
                      sub: 'Atribuir e acompanhar tarefas',
                      color: const Color(0xFFF39C12),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TarefasPage())),
                    ),
                  if (userTipo == 'admin')
                    _menuItem(
                      icon: Icons.manage_accounts,
                      label: 'Gerir Utilizadores',
                      sub: 'Administrar contas e perfis',
                      color: const Color(0xFFE74C3C),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              const UtilizadoresPage())),
                    ),
                ],
              ),
            ),
          ),
        ],
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
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(sub,
            style:
            const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing:
        const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

// ── Página de gestão de utilizadores (só admin) ──────────────────

class UtilizadoresPage extends StatelessWidget {
  const UtilizadoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE74C3C),
        title: const Text('Gerir Utilizadores',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
        FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Nenhum utilizador encontrado.'));
          }
          final users = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (_, i) {
              final data = users[i].data() as Map<String, dynamic>;
              final tipo = data['tipo'] ?? 'doador';

              Color badgeColor;
              switch (tipo) {
                case 'admin':
                  badgeColor = const Color(0xFFE74C3C);
                  break;
                case 'operador':
                  badgeColor = const Color(0xFF3498DB);
                  break;
                default:
                  badgeColor = const Color(0xFF2ECC71);
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: badgeColor.withOpacity(0.15),
                    child: Icon(Icons.person, color: badgeColor),
                  ),
                  title: Text(data['name'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600)),
                  subtitle: Text(data['email'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButton<String>(
                          value: tipo,
                          underline: const SizedBox(),
                          isDense: true,
                          style: TextStyle(
                              color: badgeColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                          items: const [
                            DropdownMenuItem(
                                value: 'admin', child: Text('Admin')),
                            DropdownMenuItem(
                                value: 'operador',
                                child: Text('Operador')),
                            DropdownMenuItem(
                                value: 'doador', child: Text('Doador')),
                          ],
                          onChanged: (novoTipo) async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(users[i].id)
                                .update({'tipo': novoTipo});
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                    Text('Perfil actualizado!')));
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title:
                              const Text('Eliminar utilizador'),
                              content: Text(
                                  'Tens a certeza que queres eliminar "${data['name']}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, true),
                                  child: const Text('Eliminar',
                                      style: TextStyle(
                                          color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirmar == true) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(users[i].id)
                                .delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Utilizador eliminado!')));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}