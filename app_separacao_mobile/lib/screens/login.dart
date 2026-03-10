import 'package:flutter/material.dart';
import '../services/apiService.dart';
import '../models/Usuario.dart';
import 'homeScreen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final ApiService _api = ApiService();
  
  bool _isLoading = false;

  Future<void> _fazerLogin() async {
    // 1. Validação simples para não enviar vazio
    if (_usuarioController.text.isEmpty || _senhaController.text.isEmpty) {
      _mostrarErro('Preencha todos os campos!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Chama o Java que nós já configuramos perfeitamente
      Usuario usuarioLogado = await _api.login(
        _usuarioController.text.trim(),
        _senhaController.text.trim(),
      );

      if (!mounted) return;
      
      // 3. Sucesso! Vai para a tela Home com o usuário
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(usuario: usuarioLogado),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarErro('Credenciais inválidas ou erro no servidor.');

      print('============= ERRO REAL DO LOGIN: $e =============');
      
      _mostrarErro('Credenciais inválidas ou erro no servidor.');
    }
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco
      body: Center(
        child: SingleChildScrollView( // Permite rolar a tela se o teclado abrir
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              Image.asset(
                'assets/aromasil.png',
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 80),

              // --- CAMPO DE USUÁRIO ---
              TextField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  labelText: 'Usuário',
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Cantos modernos
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- CAMPO DE SENHA ---
              TextField(
                controller: _senhaController,
                obscureText: true, // Esconde a senha com pontinhos
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- BOTÃO ENTRAR ---
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AAD), // Azul parecido com o da logo
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _fazerLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'ENTRAR',
                          style: TextStyle(
                            fontSize: 18, 
                            color: Colors.white, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _usuarioController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}