class LogProdutividade {
  final int id;
  final String? dataInicio;
  final String? dataFim;
  final int? quantidadeItens;
  final String tipoAtividade;
  // Aqui poderíamos mapear o objeto Usuario inteiro se quiséssemos
  final int usuarioId; 

  LogProdutividade({
    required this.id,
    this.dataInicio,
    this.dataFim,
    this.quantidadeItens,
    required this.tipoAtividade,
    required this.usuarioId,
  });

  factory LogProdutividade.fromJson(Map<String, dynamic> json) {
    return LogProdutividade(
      id: json['id'],
      dataInicio: json['dataInicio'],
      dataFim: json['dataFim'],
      quantidadeItens: json['quantidadeItens'],
      tipoAtividade: json['tipoAtividade'] ?? 'DESCONHECIDO',
      // O Spring pode retornar o objeto Usuario aninhado. 
      // Pegamos apenas o ID para simplificar por enquanto.
      usuarioId: json['usuario'] != null ? json['usuario']['id'] : 0,
    );
  }
}