import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para autenticação de usuários
import 'package:cloud_firestore/cloud_firestore.dart'; // Para salvar dados no Firestore
import 'home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controladores para capturar dados do usuário nos campos de texto
  final _nameController = TextEditingController(); // Nome do usuário
  final _emailController = TextEditingController(); // Email
  final _passwordController = TextEditingController(); // Senha

  final _auth = FirebaseAuth.instance; // Instância de autenticação
  final _firestore = FirebaseFirestore.instance; // Instância do Firestore

  bool _isLoading = false; // Flag para indicar carregamento durante o cadastro

  // Função que executa o cadastro do usuário
  Future<void> _signup() async {
    setState(() => _isLoading = true); // Mostra indicador de carregamento

    try {
      // Cria usuário no Firebase Authentication com email e senha
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(), // Remove espaços extras
        password: _passwordController.text.trim(),
      );

      // Obtém o UID único do usuário criado
      String uid = userCredential.user!.uid;

      // Salva dados do usuário no Firestore
      await _firestore.collection('users').doc(uid).set({
        'name': _nameController.text.trim(), // Nome do usuário
        'email': _emailController.text.trim(), // Email
        'created_at': FieldValue.serverTimestamp(), // Timestamp da criação
      });

      // Cadastro concluído, navega para a HomePage
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Trata erros específicos de autenticação
      String message = '';
      if (e.code == 'weak-password') {
        message = 'Senha muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email já cadastrado.';
      } else {
        message = e.message ?? 'Erro desconhecido.';
      }

      // Exibe mensagem de erro em um SnackBar
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      // Captura qualquer outro tipo de erro
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => _isLoading = false); // Esconde indicador de carregamento
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta')), // Barra superior
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          // Permite rolagem se teclado cobrir campos
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Tela de cadastro', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 24),

              // Campo de nome
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Nome', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              // Campo de email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              // Campo de senha
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                    labelText: 'Senha', border: OutlineInputBorder()),
                obscureText: true, // Oculta a senha digitada
              ),
              const SizedBox(height: 16),

              // Botão de cadastro ou indicador de loading
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signup, // Chama função de cadastro
                      child: const Text('Criar Conta'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}