// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Autenticação
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores de texto para capturar email e senha
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance; // Instância do FirebaseAuth
  final _firestore = FirebaseFirestore.instance; // Instância do Firestore

  bool _isLoading = false; // Flag para mostrar indicador de carregamento

  // Função que executa o login
  Future<void> _login() async {
    setState(() => _isLoading = true); // Mostra loading

    try {
      // Tenta logar com email e senha
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Obtém UID do usuário logado
      String uid = userCredential.user!.uid;

      // Busca dados do usuário no Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      // ignore: unused_local_variable
      String userName = '';
      if (userDoc.exists) {
        userName = userDoc.get('name') ?? '';
      }

      // Navega para HomePage após login, com o Firestore já carregado
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Captura possíveis erros do Firebase
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta.';
      } else {
        message = e.message ?? 'Erro desconhecido.';
      }

      // Mostra mensagem de erro em um SnackBar
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      // Captura outros tipos de erro
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => _isLoading = false); // Esconde loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')), // Barra superior
      body: Padding(
        padding: const EdgeInsets.all(16), // Espaçamento interno
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
          children: [
            const Text('Tela de login', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 24), // Espaço entre elementos

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
              obscureText: true, // Oculta a senha
            ),
            const SizedBox(height: 16),

            // Botão de login ou loading
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login, // Chama função de login
                    child: const Text('Entrar'),
                  ),
            const SizedBox(height: 16),

            // Botão para ir para cadastro
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupPage()),
                );
              },
              child: const Text('Criar nova conta'),
            )
          ],
        ),
      ),
    );
  }
}