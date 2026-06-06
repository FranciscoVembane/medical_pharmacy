import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _senhaVisivel = false;

  Future<void> _login() async {
    // Validações
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor insira o email.')));
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insira um email válido.')));
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor insira a senha.')));
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('A senha deve ter pelo menos 6 caracteres.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomePage()));
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'user-not-found':
          message = 'Utilizador não encontrado.';
          break;
        case 'wrong-password':
          message = 'Senha incorrecta.';
          break;
        case 'invalid-email':
          message = 'Email inválido.';
          break;
        case 'invalid-credential':
          message = 'Email ou senha incorrectos.';
          break;
        case 'too-many-requests':
          message = 'Demasiadas tentativas. Tente mais tarde.';
          break;
        default:
          message = 'Erro: ${e.message}';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2ECC71),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_pharmacy,
                      color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Medical Pharmacy',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2ECC71))),
              ),
              const Center(
                child: Text('Gestão de medicamentos e beneficiários',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: !_senhaVisivel,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_senhaVisivel
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _senhaVisivel = !_senhaVisivel),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF2ECC71)))
                  : SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2ECC71),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _login,
                        child: const Text('Entrar',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2ECC71)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SignupPage())),
                  child: const Text('Criar nova conta',
                      style: TextStyle(color: Color(0xFF2ECC71))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
