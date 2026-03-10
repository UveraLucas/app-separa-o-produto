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
      // fazendo o pedido sumir caso ele tenha sido finalizado!
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
                        
                        // Verifica se o pedido já começou a ser separado
                        bool emAndamento = pedido.status == 'EM_SEPARACAO' || pedido.status == 'EM_SEPARAÇÃO' || pedido.status == 'EM_CONFERENCIA';

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                          ),
                          clipBehavior: Clip.hardEdge, // Faz o efeito de clique respeitar a borda arredondada
                          child: InkWell(
                            onTap: () => _abrirPedido(pedido), // Ação ao clicar em qualquer lugar do cartão
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              
                              // Ícone muda de cor se já estiver em andamento
                              leading: CircleAvatar(
                                backgroundColor: emAndamento ? Colors.orange : Colors.blue,
                                child: Icon(
                                  emAndamento ? Icons.play_arrow : Icons.local_shipping, 
                                  color: Colors.white
                                ),
                              ),
                              
                              title: Text(
                                'Pedido: ${pedido.numeroErp}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 18,
                                  color: emAndamento ? Colors.orange[800] : const Color(0xFF004AAD),
                                ),
                              ),
                              
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.person, size: 16, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${pedido.codigoCliente} - ${pedido.nomeCliente}',
                                            style: const TextStyle(
                                              fontSize: 15, 
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${pedido.cidade} - ${pedido.estado}',
                                            style: const TextStyle(
                                              fontSize: 14, 
                                              color: Colors.black54,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Adiciona uma setinha no final indicando que é clicável (substituindo o botão)
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}