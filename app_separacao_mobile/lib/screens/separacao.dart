import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/Pedidos.dart'; // Verifique se o caminho do seu model está correto
import '../models/ItemPedido.dart';
import 'package:app_separacao_mobile/models/Usuario.dart';
import '../services/apiService.dart';

class SeparacaoScreen extends StatefulWidget {
  final Usuario usuario;
  final Pedido pedido;
  final int logId; // ID do log de produtividade gerado na Home

  const SeparacaoScreen({
    Key? key,
    required this.usuario,
    required this.pedido,
    required this.logId,
  }) : super(key: key);

  @override
  State<SeparacaoScreen> createState() => _SeparacaoScreenState();
}

class _SeparacaoScreenState extends State<SeparacaoScreen> {
  final ApiService _api = ApiService();
  
  // Variáveis para o Coletor a Laser Físico
  final TextEditingController _bipController = TextEditingController();
  final FocusNode _bipFocusNode = FocusNode();

  List<ItemPedido> _itens = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // MÁGICA 1: Pega os itens que já vieram da Home. Fim da tela branca!
    _itens = widget.pedido.itens;
    
    // MÁGICA 2: Já deixa o leitor físico engatilhado ao abrir a tela
    Future.delayed(Duration.zero, () => _bipFocusNode.requestFocus());
  }

  @override
  void dispose() {
    _bipController.dispose();
    _bipFocusNode.dispose();
    super.dispose();
  }

  // --- LÓGICA DE PROCESSAR O CÓDIGO DE BARRAS ---
  // Crie o tocador de áudio no topo da sua classe (junto com as variáveis _itens, etc)
  final AudioPlayer _audioPlayer = AudioPlayer();
Future<void> _processarBip(String codigoLido) async {
    // 1. Limpa sujeiras, espaços e "Enters" invisíveis que o leitor pode mandar
    String codigo = codigoLido.trim();

    if (codigo.isEmpty) return;

    _bipController.clear();
    _bipFocusNode.requestFocus();

    // 2. VERIFICAÇÃO INTELIGENTE
    bool produtoPertenceAoPedido = _itens.any((item) => item.codigoBarras == codigo);

    if (!produtoPertenceAoPedido) {
      // MOSTRA A MENSAGEM PRIMEIRO! (Garante que o operador vai ver o erro)
      _mostrarErro('ERRO: Código $codigo não pertence a este pedido!');
      
      // Tenta tocar o áudio com proteção (se falhar, não trava o resto)
      try {
        await _audioPlayer.play(AssetSource('erro.mp3'));
      } catch (e) {
        print('Erro ao carregar o som: $e'); 
      }
      
      return; // Para tudo aqui e não chama o Java
    }

    // 3. SE CHEGOU AQUI, O PRODUTO ESTÁ CERTO!
    setState(() => _isLoading = true);

    try {
      await _api.biparProduto(widget.pedido.id, codigo);

      setState(() {
        for (var item in _itens) {
          if (item.codigoBarras == codigo) {
            item.qtdSeparada += 1; 
          }
        }
        _isLoading = false;
      });

      _mostrarSucesso('Produto adicionado!');
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarErro(e.toString().replaceAll('Exception:', ''));
    }
  }
// --- LÓGICA DA CÂMERA DO CELULAR---
  Future<void> _abrirCamera() async {
    try {
      // Abre a câmera usando o pacote moderno
      var result = await BarcodeScanner.scan();
      String codigoLido = result.rawContent;

      // Se o usuário leu um código (e não apenas fechou a câmera)
      if (codigoLido.isNotEmpty) {
        _processarBip(codigoLido);
      }
    } catch (e) {
      _mostrarErro('Erro ao acessar a câmera: $e');
    }
  }

  // --- LÓGICA DE FINALIZAR O TRABALHO ---
  Future<void> _finalizarSeparacao() async {
    setState(() => _isLoading = true);
    try {
      // Calcula o total de itens que foram bipados com sucesso
      int totalSeparado = _itens.fold(0, (sum, item) => sum + item.qtdSeparada);
      
      // Chama a função que consertamos lá no api_service.dart
      await _api.finalizarTrabalho(widget.logId, totalSeparado);

      if (!mounted) return;
      _mostrarSucesso('Separação finalizada com sucesso!');
      
      // Volta para a tela Home
      Navigator.pop(context); 
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarErro('Erro ao finalizar: $e');
    }
  }

  // --- MENSAGENS NA TELA ---
  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _mostrarSucesso(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  // --- DESENHO DA TELA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido: ${widget.pedido.numeroErp}'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // CAMPO DE TEXTO PARA O COLETOR FÍSICO (Laser)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _bipController,
              focusNode: _bipFocusNode,
              decoration: const InputDecoration(
                labelText: 'Código de Barras (Use o Coletor ou digite)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code_scanner),
              ),
              onSubmitted: _processarBip, // Dispara ao apertar "Enter" no teclado/coletor
            ),
          ),

          // BARRA DE CARREGAMENTO
          if (_isLoading) const LinearProgressIndicator(),

          // LISTA DE PRODUTOS
          Expanded(
            child: ListView.builder(
              itemCount: _itens.length,
              itemBuilder: (context, index) {
                final item = _itens[index];
                final bool concluido = item.qtdSeparada >= item.qtdSolicitada;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: concluido ? Colors.green[50] : Colors.white,
                  child: ListTile(
                    leading: Icon(
                      concluido ? Icons.check_circle : Icons.inventory_2,
                      color: concluido ? Colors.green : Colors.grey,
                      size: 32,
                    ),
                    title: Text(
                      item.descricao,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // O SEU NOVO SUBTITLE (COM CÓDIGO E MEDIDA):
                    subtitle: Text(
                      'Cód Sistema: ${item.codPro}   |   Medida: ${item.unMed}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    // O CONTADOR QUE TINHA SUMIDO:
                    trailing: Text(
                      '${item.qtdSeparada} / ${item.qtdSolicitada}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: concluido ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // BOTÃO DE FINALIZAR NO RODAPÉ
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _finalizarSeparacao,
                icon: const Icon(Icons.done_all, color: Colors.white),
                label: const Text(
                  'FINALIZAR SEPARAÇÃO', 
                  style: TextStyle(fontSize: 18, color: Colors.white)
                ),
              ),
            ),
          )
        ],
      ),
      
      // BOTÃO FLUTUANTE DA CÂMERA DO CELULAR
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCamera,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
      // Posiciona o botão flutuante um pouco acima para não sobrepor o botão de finalizar
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}