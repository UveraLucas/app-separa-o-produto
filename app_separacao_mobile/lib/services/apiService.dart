import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Usuario.dart';
import '../models/Pedidos.dart';
import '../models/logProdutividade.dart'; // Ajuste o nome do arquivo se necessário

class ApiService {
  // Lembre-se de colocar o IP do seu computador aqui para testar no Wi-Fi!
  static const String baseUrl = 'http://192.168.1.248:8080/api'; 


  Future<Usuario> login(String usuarioInput, String senha) async {
    // 1. Aponta para a rota certa (/auth/login)
    // 2. Envia como RequestParam usando o .replace(queryParameters)
    final uri = Uri.parse('$baseUrl/auth/login').replace(queryParameters: {
      'matricula': usuarioInput, // O Java exige que o nome seja 'matricula'
      'senha': senha,
    });

    // 3. Dispara o POST vazio (pois os dados já foram na URL acima)
    final response = await http.post(uri);

    if (response.statusCode == 200) {
      // Deu certo! Converte a resposta do Java de volta para o formato Flutter
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      // Se a senha estiver errada, o Java vai mandar um Status 401
      throw Exception('Falha no login: Status ${response.statusCode} - ${response.body}');
    }
  }

  // --- BUSCAR PEDIDOS DINAMICAMENTE POR STATUS ---
  Future<List<Pedido>> getPedidosPorStatus(String status) async {
    final uri = Uri.parse('$baseUrl/pedidos/listar/$status');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Pedido.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar pedidos: ${response.body}');
    }
  }

  // --- INICIAR/RETOMAR SEPARAÇÃO ---
  Future<LogProdutividade> iniciarSeparacao(String usuarioErp, String numeroPedido) async {
    final uri = Uri.parse('$baseUrl/producao/iniciar').replace(queryParameters: {
      'Usuario_erp': usuarioErp, 
      'numeroPedido': numeroPedido, 
    });

    final response = await http.post(uri);

    if (response.statusCode == 200) {
      return LogProdutividade.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao iniciar separação: ${response.body}');
    }
  }

// --- BIPAR PRODUTO ---
  Future<void> biparProduto(int pedidoId, String codigoBarras) async {
    // CORREÇÃO: Colocamos o pedidoId diretamente dentro da URL (PathVariable)
    final uri = Uri.parse('$baseUrl/producao/$pedidoId/bipar').replace(queryParameters: {
      'codigoBarras': codigoBarras,
    });

    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception('Erro ao bipar: ${response.body}');
    }
  }

  // --- FINALIZAR TRABALHO ---
  Future<void> finalizarTrabalho(int logId, int totalSeparado) async {
    // CORREÇÃO 1: logId vai direto na URL (PathVariable)
    // CORREÇÃO 2: O Java exige que o nome da variável de quantidade seja 'qtd'
    final uri = Uri.parse('$baseUrl/producao/finalizar/$logId').replace(queryParameters: {
      'qtd': totalSeparado.toString(), 
    });

    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception('Erro ao finalizar: ${response.body}');
    }
  }
}