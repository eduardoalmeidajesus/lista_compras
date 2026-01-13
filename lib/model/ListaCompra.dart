class ListaCompra {
  int? id;
  String nome;
  bool comprada;
  String tipo;

  ListaCompra({this.id, required this.nome, this.comprada = false, required this.tipo});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'comprada': comprada ? 1 : 0,
      'tipo': tipo,
    };
  }

  factory ListaCompra.fromJson(Map<String, dynamic> json) {
    return ListaCompra(
      id: json['id'],
      nome: json['nome'],
      comprada: json['comprada'] == 1,
      tipo: json['tipo'] ?? 'Supermercado',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ListaCompra && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}