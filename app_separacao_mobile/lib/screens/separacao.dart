import 'package:flutter/material.dart';
import '../models/Pedidos.dart';
import '../models/ItemPedido.dart';
import '../models/Usuario.dart';
import '../services/apiService.dart';

class SeparacaoScreen extends StatefulWidget {
  final Usuario usuario;
  final Pedido pedido;
  final int logId;

  const SeparacaoScreen({
    super.key,
    required this.usuario,
    required this.pedido,
    required this.logId,
  });

  @override
  State<SeparacaoScreen> createState() => _SeparacaoScreenState();
}

class _SeparacaoScreenState extends State<SeparacaoScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _bipController = TextEditingController();
  final FocusNode _bipFocusNode = FocusNode();

  List<ItemPedido> _itens = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  Future<void> _carregarItens() async {
    try {
      final itens = await _api.getItensDoPedido(widget.pedido.id);
      setState(() {
        _itens = itens;
        _isLoading = false;
      });
      Future.delayed(Duration.zero, () => _bipFocusNode.requestFocus());
    } catch (e) {
      _mostrarErro('Erro ao carregar itens: $e');
    }
  }

  Future<void> _processarBip(String codigo) async {
    if (codigo.isEmpty) return;
    _bipController.clear();
    _bipFocusNode.requestFocus();

    try {
      await _api.biparProduto(widget.pedido.id, codigo);
      _mostrarSucesso('Produto bipado!');
      _carregarItens(); 
    } catch (e) {
      _mostrarErro(e.toString().replaceAll('Exception:', ''));
    }
  }

  Future<void> _finalizarSeparacao() async {
    // Verifica se tem pendências (itens zerados)
    bool temItensZerados = _itens.any((i) => i.qtdSeparada == 0);
    
    if (temItensZerados) {
      bool confirmar = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Itens Zerados'),
          content: const Text('Existem itens não bipados. Eles serão enviados para análise na Conferência. Confirmar?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Não')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sim')),
          ],
        ),
      ) ?? false;

      if (!confirmar) return;
    }

    setState(() => _isLoading = true);
    try {
      int totalSeparado = _itens.fold(0, (sum, item) => sum + item.qtdSeparada);
      await _api.finalizarTrabalho(widget.logId, totalSeparado);
      
      if (!mounted) return;
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido enviado para Conferência!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      _mostrarErro('Erro ao finalizar: $e');
      setState(() => _isLoading = false);
    }
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red, duration: const Duration(seconds: 2)),
    );
  }

  void _mostrarSucesso(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green, duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Separação', style: TextStyle(fontSize: 16)),
            Text(widget.pedido.numeroErp, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregarItens)
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: TextField(
              controller: _bipController,
              focusNode: _bipFocusNode,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Bipar Produto (Código de Barras)',
                prefixIcon: Icon(Icons.qr_code_scanner),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: _processarBip,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.number,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _itens.length,
                    itemBuilder: (context, index) {
                      final item = _itens[index];
                      
                      Color cardColor = Colors.white;
                      if (item.qtdSeparada >= item.qtdSolicitada) {
                        cardColor = Colors.green.shade100;
                      }

                      return Card(
                        color: cardColor,
                        child: ListTile(
                          title: Text(item.descricao, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('EAN: ${item.codigoBarras}'),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: item.qtdSolicitada > 0 ? item.qtdSeparada / item.qtdSolicitada : 0,
                                backgroundColor: Colors.grey[300],
                                color: Colors.blue,
                              ),
                            ],
                          ),
                          trailing: Text(
                            '${item.qtdSeparada} / ${item.qtdSolicitada}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isLoading ? null : _finalizarSeparacao,
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text('FINALIZAR SEPARAÇÃO', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}