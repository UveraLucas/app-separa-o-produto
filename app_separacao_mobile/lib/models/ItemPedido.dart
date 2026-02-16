// lib/models/ItemPedido.dart (Crie este arquivo se não tiver, ou adicione no pedido)

class ItemPedido {
  final int id;
  final String codigoBarras;
  final String descricao;
  final int qtdSolicitada;
  final int qtdSeparada;
  final bool itemCortado; // Novo campo

  ItemPedido({
    required this.id,
    required this.codigoBarras,
    required this.descricao,
    required this.qtdSolicitada,
    required this.qtdSeparada,
    required this.itemCortado,
  });

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      id: json['id'],
      codigoBarras: json['codigoBarras'],
      descricao: json['descricao'],
      qtdSolicitada: json['qtdSolicitada'],
      qtdSeparada: json['qtdSeparada'],
      itemCortado: json['itemCortado'] ?? false, // Se vier nulo, assume falso
    );
  }
}