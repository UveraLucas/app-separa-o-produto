import 'package:flutter/material.dart';
import '../models/Usuario.dart';
import '../models/Pedidos.dart';
import '../services/apiService.dart';
import 'separacao.dart';

class ListaPedidosScreen extends StatefulWidget {
  final Usuario usuario;
  final String titulo;
  final String statusBusca; 

  const ListaPedidosScreen({
    Key? key,
    required this.usuario,
    required this.titulo,
    required this.statusBusca,
  }) : super(key: key);

  @override
  State<ListaPedidosScreen> createState() => _ListaPedidosScreenState();
}

class _ListaPedidosScreenState extends State<ListaPedidosScreen> {
  final ApiService _api = ApiService();
  List<Pedido> _pedidos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  Future<void> _carregarPedidos() async {
    setState(() => _isLoading = true);
    try {
      // Chama a API enviando o status exato que a tela pediu
      final pedidosDaApi = await _api.getPedidosPorStatus(widget.statusBusca);
      
      setState(() {
        _pedidos = pedidosDaApi;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarErro('Erro ao carregar pedidos: $e');
    }
  }

  Future<void> _abrirPedido(Pedido pedido) async {
    try {
      // Cria ou retoma o Log de Produtividade no Java
      final logGerado = await _api.iniciarSeparacao(
        widget.usuario.usuarioErp, 
        pedido.numeroErp
      );

      if (!mounted) return;

      // Navega para a tela de Bipar
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeparacaoScreen(
            usuario: widget.usuario,
            pedido: pedido,
            logId: logGerado.id, 
          ),
        ),
      );

      // Quando o operador voltar da tela de bipar, atualiza a lista automaticamente
      _carregarPedidos();

    } catch (e) {
      _mostrarErro('Erro ao iniciar tarefa: $e');
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: const Color(0xFF004AAD),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarPedidos,
              child: _pedidos.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(top: 100.0),
                          child: Center(
                            child: Text(
                              'Nenhum pedido encontrado.',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ),
                        )
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _pedidos.length,
                      itemBuilder: (context, index) {
                        final pedido = _pedidos[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.assignment, color: Colors.white),
                            ),
                            title: Text(
                              pedido.numeroErp,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('Itens: ${pedido.itens.length}'),
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.statusBusca == 'EM_SEPARACAO' 
                                    ? Colors.orange // Laranja se for retomar
                                    : Colors.blue, // Azul se for começar novo
                              ),
                              onPressed: () => _abrirPedido(pedido),
                              child: Text(
                                widget.statusBusca == 'EM_SEPARACAO' ? 'CONTINUAR' : 'INICIAR', 
                                style: const TextStyle(color: Colors.white)
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}