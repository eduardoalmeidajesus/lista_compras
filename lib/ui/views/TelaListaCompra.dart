import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lista_compras/model/ListaCompra.dart';
import 'package:lista_compras/model/ItemCompra.dart';
import 'package:lista_compras/model/Setor.dart';
import 'package:lista_compras/repository/SetorRepository.dart';
import 'package:lista_compras/ui/viewmodels/ItemCompraViewModel.dart';
import 'package:provider/provider.dart';

class TelaListaCompra extends StatefulWidget {
  final ListaCompra lista;

  const TelaListaCompra({super.key, required this.lista});

  @override
  State<TelaListaCompra> createState() => _TelaListaCompraState();
}

class _TelaListaCompraState extends State<TelaListaCompra> {
  late ItemCompraViewModel? icvm = null;
  late StreamSubscription _errorSubscription;
  late Future<String> _conectado;
  List<Setor> setores = [];
  Setor? setorFiltro;
  late SetorRepository _setorRepo;
  bool _carregandoSetores = true;

  void configurar() async {
    _errorSubscription = icvm!.errorStream.listen((msg) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), duration: Duration(seconds: 4)));
    });

    try {
      await _setorRepo.connect();

      setores = await _setorRepo.getByTipoLista(widget.lista.tipo);
      // opção de setor = todos
      setores.insert(0, Setor(id: -1, nome: "Todos", tipoLista: widget.lista.tipo));
      setorFiltro = setores[0];

      // carrega itens quando tela abrir
      await icvm!.carregarItens(widget.lista.id!);

      setState(() {
        _carregandoSetores = false;
      });
    } catch (e) {
      print("Erro ao carregar setores: $e");
      setState(() {
        _carregandoSetores = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _setorRepo = SetorRepository.create();
  }

  @override
  void dispose() {
    _errorSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // verifica se o viewmodel ja foi iniciado
    if (icvm == null) {
      icvm = Provider.of<ItemCompraViewModel>(context);
      _conectado = icvm!.conectar();
      configurar();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.lista.nome),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Chip(
              label: Text("Faltam: ${icvm!.quantidadeFaltante}"),
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _conectado,
        builder: (context, snapshot) {
          if (!snapshot.hasData || _carregandoSetores) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // filtro por setor
              Padding(
                padding: EdgeInsets.all(8.0),
                child: DropdownButton<Setor>(
                  value: setorFiltro,
                  items: setores.map((Setor setor) {
                    return DropdownMenuItem<Setor>(
                      value: setor,
                      child: Text(setor.nome),
                    );
                  }).toList(),
                  onChanged: (Setor? novoSetor) {
                    setState(() {
                      setorFiltro = novoSetor;
                    });
                    if (novoSetor!.id == -1) {
                      icvm!.carregarItens(widget.lista.id!);
                    } else {
                      icvm!.carregarItensPorSetor(widget.lista.id!, novoSetor.id!);
                    }
                  },
                ),
              ),
              Expanded(
                child: icvm!.itens.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_basket, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "Nenhum item na lista",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Clique no botão + para adicionar itens",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: icvm!.itens.length,
                  itemBuilder: (BuildContext ctx, int idx) {
                    return itemLista(icvm!.itens[idx]);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoItem(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget itemLista(ItemCompra item) {
    return Card(
      color: item.comprado ? Colors.grey[200] : null,
      child: ListTile(
        leading: Checkbox(
          value: item.comprado,
          onChanged: (value) {
            icvm!.marcarComoComprado(item, value ?? false);
          },
        ),
        title: Text(
          item.nome,
          style: TextStyle(
            decoration: item.comprado ? TextDecoration.lineThrough : null,
            color: item.comprado ? Colors.grey : null,
          ),
        ),
        subtitle: item.setorNome != null ? Text("Setor: ${item.setorNome}") : null,
        trailing: IconButton(
          onPressed: () => _confirmarRemocaoItem(item),
          icon: Icon(Icons.delete, color: Colors.red),
        ),
      ),
    );
  }

  void _confirmarRemocaoItem(ItemCompra item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar Remoção"),
        content: Text("Deseja remover o item '${item.nome}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              icvm!.removerItem(item);
              Navigator.pop(context);
            },
            child: Text("Remover"),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoItem(BuildContext context) {
    icvm!.limparCampos();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Novo Item"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: icvm!.ctrlNomeItem,
                  decoration: InputDecoration(
                    labelText: "Nome do Item",
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                SizedBox(height: 16),
                DropdownButton<Setor>(
                  value: icvm!.setorSelecionado,
                  hint: Text("Selecione um setor"),
                  items: setores.where((s) => s.id != -1).map((Setor setor) {
                    return DropdownMenuItem<Setor>(
                      value: setor,
                      child: Text(setor.nome),
                    );
                  }).toList(),
                  onChanged: (Setor? novoSetor) {
                    setState(() {
                      icvm!.setorSelecionado = novoSetor;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  if (icvm!.validarNome(icvm!.ctrlNomeItem.text) == null && icvm!.setorSelecionado != null) {
                    icvm!.confirmarItem();
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Preencha todos os campos corretamente")));
                  }
                },
                child: Text("Adicionar"),
              ),
            ],
          );
        },
      ),
    );
  }
}