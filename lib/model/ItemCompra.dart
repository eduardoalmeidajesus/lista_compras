class ItemCompra {
  int? id;
  String nome;
  bool comprado;
  int listaCompraId;
  int setorId;
  String? setorNome;

  ItemCompra({
    this.id,
    required this.nome,
    this.comprado = false,
    required this.listaCompraId,
    required this.setorId,
    this.setorNome,
  });

  // converte objeto para map pra salvar no sqlite
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'comprado': comprado ? 1 : 0,
      'listaCompraId': listaCompraId,
      'setorId': setorId,
    };
  }

  // cria objeto do map para buscar no banco
  factory ItemCompra.fromJson(Map<String, dynamic> json) {
    return ItemCompra(
      id: json['id'],
      nome: json['nome'],
      comprado: json['comprado'] == 1,
      listaCompraId: json['listaCompraId'],
      setorId: json['setorId'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ItemCompra && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}