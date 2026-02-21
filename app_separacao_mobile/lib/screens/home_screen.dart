import 'package:flutter/material.dart';
import '../models/Usuario.dart';
import '../models/Pedidos.dart';
import '../services/apiService.dart';
import 'separacao.dart'; // Importe a tela de separação
// import 'conferencia_screen.dart'; // Futuramente você criará essa

class HomeScreen extends StatefulWidget {
  final Usuario usuario; // Recebemos quem logou (para registrar nos logs)

  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    // Configura 2 abas: Separação e Conferência
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE INICIAR TAREFA ---
  // Quando o usuário clica em "SEPARAR" ou "CONFERIR"
  Future<void> _iniciarTarefa(Pedido pedido, bool isSeparacao) async {
    try {
      // 1. Avisa o Backend que a tarefa começou (Gera Log e Muda Status)
      final logGerado = await _api.iniciarSeparacao(
        widget.usuario.usuarioErp,
        pedido.numeroErp
      );

      if (!mounted) return;

      // 2. Navega para a tela correta
      if (isSeparacao) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeparacaoScreen(
              usuario: widget.usuario,
              pedido: pedido,
              logId: logGerado.id, // Passamos o ID do Log para finalizar depois
            ),
          ),
        );
      } else {
        // Lógica futura da Conferência
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Módulo de Conferência em construção! 🚧')),
        );
      }

      // 3. Ao voltar, atualiza a lista (para o pedido sumir da aba)
      setState(() {});

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao iniciar: ${e.toString().replaceAll('Exception:', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- WIDGET QUE MONTA A LISTA DE PEDIDOS ---
  Widget _buildListaPedidos({required String status, required String labelBotao, required Color corBotao, required bool isSeparacao}) {
    return FutureBuilder<List<Pedido>>(
      future: _api.getPedidosPorStatus(status), // Busca na API
      builder: (context, snapshot) {
        // Estado 1: Carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Estado 2: Erro
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 10),
                Text('Erro de conexão:\n${snapshot.error}', textAlign: TextAlign.center),
                ElevatedButton(
                  onPressed: () => setState(() {}), // Tenta de novo
                  child: const Text('Tentar Novamente'),
                )
              ],
            ),
          );
        }

        // Estado 3: Lista Vazia
// Estado 3: Lista Vazia
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => setState(() {}), // Puxar pra baixo atualiza
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Força a tela a ser "puxável"
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7, // Ocupa a tela inteira
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      Text('Nenhum pedido "$status"', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      const SizedBox(height: 20),
                      Text('Puxe para baixo para atualizar ↓', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Estado 4: Sucesso (Mostra a Lista)
        final pedidos = snapshot.data!;
        
        return RefreshIndicator(
          onRefresh: () async => setState(() {}), // Puxar pra baixo atualiza
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(), // Garante que a lista também pode ser puxada
            padding: const EdgeInsets.all(8),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: corBotao.withOpacity(0.2),
                    child: Icon(Icons.assignment, color: corBotao),
                  ),
                  title: Text(
                    pedido.numeroErp, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(pedido.cliente),
                      Text(
                        'Itens: ${pedido.itens.length}', 
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corBotao,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _iniciarTarefa(pedido, isSeparacao),
                    child: Text(labelBotao),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('WMS Coletor', style: TextStyle(fontSize: 18)),
            Text(
              'Olá, ${widget.usuario.nome}', 
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'), // Sai do app
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'A SEPARAR', icon: Icon(Icons.shopping_cart_checkout)),
            Tab(text: 'A CONFERIR', icon: Icon(Icons.fact_check)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ABA 1: Lista pedidos PENDENTES
          _buildListaPedidos(
            status: 'PENDENTE', 
            labelBotao: 'SEPARAR', 
            corBotao: Colors.blue,
            isSeparacao: true,
          ),
          
          // ABA 2: Lista pedidos AGUARDANDO_CONFERENCIA
          _buildListaPedidos(
            status: 'AGUARDANDO_CONFERENCIA', 
            labelBotao: 'CONFERIR', 
            corBotao: Colors.orange,
            isSeparacao: false, // Aqui mudaremos para true quando tiver a tela de conferência
          ),
        ],
      ),
    );
  }
}