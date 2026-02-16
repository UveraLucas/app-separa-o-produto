class Usuario {
  final int id;
  final String nome;
  final String usuarioErp; // Sua matrícula/login
  final String cargo;

  Usuario({
    required this.id,
    required this.nome,
    required this.usuarioErp,
    required this.cargo,
  });

  // Fábrica para criar um Usuario a partir do JSON do Spring Boot
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      // Atenção aqui: O JSON do Spring deve retornar 'usuarioErp' ou 'matricula'
      // dependendo de como ficou sua classe Java. Ajuste se necessário.
      usuarioErp: json['usuarioErp'] ?? json['matricula'] ?? '',
      cargo: json['cargo'],
    );
  }
}