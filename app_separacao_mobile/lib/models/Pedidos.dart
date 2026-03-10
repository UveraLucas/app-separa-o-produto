import 'ItemPedido.dart';

class Pedido {
  final int id;
  final String numeroErp;
  final String codigoCliente;
  final String nomeCliente;
  final String cidade;
  final String estado;
  final String status;
  final List<ItemPedido> itens; 

  Pedido({
    required this.id,
    required this.numeroErp,
    required this.codigoCliente,
    required this.nomeCliente,
    required this.cidade,
    required this.estado,
    required this.status,
    required this.itens,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    var listaJson = json['itens'] as List? ?? [];
    List<ItemPedido> listaConvertida = listaJson
        .map((item) => ItemPedido.fromJson(item))
        .toList();

    return Pedido(
      id: json['id'] ?? 0,
      numeroErp: json['numeroErp'] ?? 'S/N',
      codigoCliente: json['codigoCliente'] ?? 'N/D',
      nomeCliente: json['nomeCliente'] ?? 'Não informado',
      cidade: json['cidade'] ?? 'N/I',
      estado: json['estado'] ?? 'UF',
      status: json['status'] ?? 'PENDENTE',
      itens: listaConvertida, 
    );
  }
}