class Setor {
  int? id;
  String nome;
  String tipoLista;

  Setor({this.id, required this.nome, required this.tipoLista});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipoLista': tipoLista,
    };
  }

  factory Setor.fromJson(Map<String, dynamic> json) {
    return Setor(
      id: json['id'],
      nome: json['nome'],
      tipoLista: json['tipoLista'] ?? 'Supermercado',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Setor && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}