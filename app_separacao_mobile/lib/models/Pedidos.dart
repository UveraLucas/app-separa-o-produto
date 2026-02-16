import 'ItemPedido.dart'; // Não esqueça de importar o modelo do Item!

class Pedido {
  final int id;
  final String numeroErp;
  final String cliente;
  final String status;
  final List<ItemPedido> itens; // A lista de produtos do pedido

  Pedido({
    required this.id,
    required this.numeroErp,
    required this.cliente,
    required this.status,
    required this.itens,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    // 1. Tratamento da Lista:
    // O backend manda uma lista chamada "itens".
    // Se vier nula (null), usamos uma lista vazia [] para não quebrar o app.
    var listaJson = json['itens'] as List? ?? [];

    // 2. Conversão:
    // Transformamos cada pedaço do JSON da lista em um objeto ItemPedido real
    List<ItemPedido> listaConvertida = listaJson
        .map((item) => ItemPedido.fromJson(item))
        .toList();

    return Pedido(
      id: json['id'],
      numeroErp: json['numeroErp'],
      cliente: json['cliente'],
      status: json['status'],
      itens: listaConvertida, // Passamos a lista já pronta
    );
  }
}