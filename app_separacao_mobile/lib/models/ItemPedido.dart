// lib/models/ItemPedido.dart (Crie este arquivo se não tiver, ou adicione no pedido)

class ItemPedido {
  int id;
  String codigoBarras;
  String descricao;
  int qtdSolicitada;
  int qtdSeparada;
  String codPro; 
  String unMed; 

  ItemPedido({
    required this.id,
    required this.codigoBarras,
    required this.descricao,
    required this.qtdSolicitada,
    required this.qtdSeparada,
    required this.codPro,
    required this.unMed,
  });

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      id: json['id'],
      codigoBarras: json['codigoBarras'],
      descricao: json['descricao'],
      qtdSolicitada: json['qtdSolicitada'],
      qtdSeparada: json['qtdSeparada'] ?? 0,
      codPro: json['codigoProduto'] ?? 'N/A', 
      unMed: json['unidadeMedida'] ?? 'UN',
    );
  }
}