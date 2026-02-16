import 'package:flutter/material.dart';
import '../services/apiService.dart';
import 'home_screen.dart'; // Certifique-se de ter criado este arquivo conforme conversamos antes

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _matriculaController = TextEditingController(); // Login
  final _senhaController = TextEditingController();     // Senha
  final _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _fazerLogin() async {
    if (_matriculaController.text.isEmpty || _senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha login e senha!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Chama o endpoint de Autenticação
      final usuario = await _apiService.login(
        _matriculaController.text,
        _senhaController.text,
      );

      if (!mounted) return;

      // Sucesso! Vai para a Home (Lista de Pedidos)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(usuario: usuario)),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString().replaceAll('Exception:', '')}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warehouse_rounded, size: 80, color: Colors.blue),
            const SizedBox(height: 10),
            const Text("WMS - Separação", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            
            // CAMPO MATRÍCULA
            TextField(
              controller: _matriculaController,
              decoration: const InputDecoration(
                labelText: 'Matrícula / Usuário',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            
            // CAMPO SENHA (NOVO)
            TextField(
              controller: _senhaController,
              obscureText: true, // Esconde a senha
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            
            // BOTÃO ENTRAR
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _fazerLogin,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('ACESSAR SISTEMA', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}