import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Usuario.dart';
import '../models/Pedidos.dart';
import '../models/ItemPedido.dart';
import '../models/logProdutividade.dart';

class ApiService {
  // Ajuste o IP conforme necessário (10.0.2.2 para emulador, IP da máquina para USB)
  // static const String baseUrl = 'http://10.0.2.2:8080/api'; 
  static const String baseUrl = 'http://127.0.0.1:8080/api'; 

  /// --- AUTENTICAÇÃO ---
  Future<Usuario> login(String matricula, String senha) async {
    final uri = Uri.parse('$baseUrl/auth/login').replace(queryParameters: {
      'matricula': matricula, // <-- A MÁGICA É AQUI! Mudamos para bater com o Java
      'senha': senha,
    });

    final response = await http.post(uri);

    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Login falhou: ${response.body}');
    }
  }

  // --- PEDIDOS ---
  Future<List<Pedido>> getPedidosPorStatus(String status) async {
    final uri = Uri.parse('$baseUrl/pedidos/listar/$status');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Pedido.fromJson(item)).toList();
    } else {
      return [];
    }
  }

  // --- ATUALIZAR STATUS DO PEDIDO ---
  Future<bool> atualizarStatusPedido(int pedidoId, String novoStatus) async {
    // Usamos queryParameters para enviar o ?status=EM_SEPARACAO
    final uri = Uri.parse('$baseUrl/pedidos/$pedidoId/status').replace(queryParameters: {
      'status': novoStatus, // <-- A CHAVE DEVE SER EXATAMENTE 'status'
    });

    final response = await http.put(uri);

    if (response.statusCode == 200) {
      return true; // Sucesso!
    } else {
      print('Erro 400: ${response.body}');
      throw Exception('Falha ao atualizar status');
    }
  }

  // --- ITENS E OPERAÇÃO ---
  Future<List<ItemPedido>> getItensDoPedido(int pedidoId) async {
    final uri = Uri.parse('$baseUrl/producao/$pedidoId/itens');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => ItemPedido.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao carregar itens');
    }
  }

  Future<void> biparProduto(int pedidoId, String codigoBarras) async {
    final uri = Uri.parse('$baseUrl/producao/$pedidoId/bipar').replace(queryParameters: {
      'codigoBarras': codigoBarras,
    });
    
    final response = await http.post(uri);
    if (response.statusCode != 200) {
      throw Exception(response.body); 
    }
  }

// --- INICIAR SEPARAÇÃO ---
  Future<LogProdutividade> iniciarSeparacao(String usuarioErp, String numeroErp) async {
    final uri = Uri.parse('$baseUrl/producao/iniciar').replace(queryParameters: {
      'Usuario_erp': usuarioErp, 
      'numeroPedido': numeroErp, // <-- Se o seu Java pedir 'pedidoId' em vez de numeroErp, me avise!
    });

    final response = await http.post(uri); // ou http.put, dependendo do seu Java

    if (response.statusCode == 200) {
      // Agora retornamos o objeto LogProdutividade, assim o logGerado.id vai funcionar!
      return LogProdutividade.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao iniciar separação: ${response.body}');
    }
  }
  

 Future<LogProdutividade> finalizarTrabalho(int logId, int quantidade) async {
     final uri = Uri.parse('$baseUrl/producao/finalizar/$logId').replace(queryParameters: {
      'qtd': quantidade.toString(),
   });
    
    final response = await http.post(uri);
    
    if (response.statusCode == 200) {
        return LogProdutividade.fromJson(jsonDecode(response.body));
    } else {
        throw Exception('Erro: ${response.body}');
    }
 }
}