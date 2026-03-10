import 'package:flutter/material.dart';
import '../models/Usuario.dart';
import 'listaPedidos.dart'; 

class HomeScreen extends StatelessWidget {
  final Usuario usuario;

  const HomeScreen({
    Key? key,
    required this.usuario,
  }) : super(key: key);

  // --- NOVA VERSÃO DO BOTÃO (Sem o Expanded e ajustado para o Grid) ---
  Widget _construirBotaoModulo({
    required BuildContext context,
    required String titulo,
    required IconData icone,
    required Color cor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        splashColor: cor.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: cor, width: 6)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 48, color: cor), // Ícone um pouco menor
              const SizedBox(height: 12),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15, // Fonte ajustada para não quebrar a palavra
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Expedição Aromasil'),
        backgroundColor: const Color(0xFF004AAD), // Azul da Aromasil
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Olá, ${usuario.nome}!\nSelecione o processo:',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            
            // --- A MÁGICA DO GRID (Lado a Lado) ---
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Define 2 colunas
                crossAxisSpacing: 16, // Espaçamento horizontal entre eles
                mainAxisSpacing: 16, // Espaçamento vertical entre eles
                childAspectRatio: 1.0, // Deixa os cartões perfeitamente quadrados
                children: [
                  
                  // 1. MÓDULO DE SEPARAÇÃO
                  _construirBotaoModulo(
                    context: context,
                    titulo: 'SEPARAÇÃO',
                    icone: Icons.inventory_2_outlined,
                    cor: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListaPedidosScreen(
                            usuario: usuario,
                            titulo: 'Pedidos em Separação',
                            statusBusca: 'PENDENTE,EM_SEPARACAO', 
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // 2. MÓDULO DE CONFERÊNCIA
                  _construirBotaoModulo(
                    context: context,
                    titulo: 'CONFERÊNCIA',
                    icone: Icons.fact_check_outlined,
                    cor: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListaPedidosScreen(
                            usuario: usuario,
                            titulo: 'Pedidos para Conferência',
                            statusBusca: 'AGUARDANDO_CONFERENCIA, EM_CONFERENCIA', 
                          ),
                        ),
                      );
                    },
                  ),

                  // NO FUTURO: Basta colar um novo _construirBotaoModulo aqui embaixo
                  // e ele vai aparecer automaticamente na linha de baixo!

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}