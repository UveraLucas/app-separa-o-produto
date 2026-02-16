import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/logProdutividade.dart';

class ApiService {
  // Endereço especial para o Emulador Android acessar o localhost do PC
  static const String baseUrl = 'http://10.0.2.2:8080/api/producao';

  // Método para INICIAR a tarefa
  Future<LogProdutividade> iniciarTrabalho(String matricula, String numeroPedido) async {
    // Monta a URL com os parâmetros (Query Params)
    // Ex: http://10.0.2.2:8080/api/producao/iniciar?matricula=mestre123&numeroPedido=ERP-001
    final uri = Uri.parse('$baseUrl/iniciar').replace(queryParameters: {
      'matricula': matricula, // Confira se no Java está 'matricula' ou 'Usuario_erp'
      'numeroPedido': numeroPedido,
    });

    try {
      final response = await http.post(uri);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Sucesso! Converte o JSON em objeto Dart
        return LogProdutividade.fromJson(jsonDecode(response.body));
      } else {
        // Erro vindo do servidor (ex: Usuário não encontrado - 404, Bad Request - 400)
        throw Exception('Erro ao iniciar: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha na conexão: $e');
    }
  }

  // Método para FINALIZAR a tarefa
  Future<LogProdutividade> finalizarTrabalho(int logId, int quantidade) async {
    final uri = Uri.parse('$baseUrl/finalizar/$logId').replace(queryParameters: {
      'qtd': quantidade.toString(),
    });

    try {
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        return LogProdutividade.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erro ao finalizar: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha na conexão: $e');
    }
  }
}