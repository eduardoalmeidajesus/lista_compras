import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lista_compras/model/ListaCompra.dart';
import 'package:lista_compras/ui/viewmodels/ListaCompraViewModel.dart';
import 'package:lista_compras/ui/viewmodels/ItemCompraViewModel.dart';
import 'package:lista_compras/ui/viewmodels/SetorViewModel.dart';
import 'package:provider/provider.dart';
import 'TelaListaCompra.dart';
import 'TelaSetores.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  late ListaCompraViewModel lcvm;
  late StreamSubscription _errorSubscription;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  void _inicializar() async {
    try {
      lcvm = Provider.of<ListaCompraViewModel>(context, listen: false);

      _errorSubscription = lcvm.errorStream.listen((msg) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), duration: Duration(seconds: 4)));
      });

      await lcvm.conectar();
      setState(() {
        _carregando = false;
        _erro = null;
      });
    } catch (e) {
      print("Erro na inicialização: $e");
      setState(() {
        _carregando = false;
        _erro = "Erro ao carregar dados: $e";
      });
    }
  }

  @override
  void dispose() {
    _errorSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListaCompraViewModel>(
      builder: (context, lcvm, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text("Listas de Compras"),
            actions: [
              IconButton(
                icon: Icon(Icons.category),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) =>
                          ChangeNotifierProvider(
                            create: (_) => SetorViewModel(),
                            child: TelaSetores(),
                          )
                      )
                  );
                },
                tooltip: "Gerenciar Setores",
              ),
            ],
          ),
          body: _carregando
              ? Center(child: CircularProgressIndicator())
              : _erro != null
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_erro!),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _carregando = true;
                      _erro = null;
                    });
                    _inicializar();
                  },
                  child: Text("Tentar Novamente"),
                ),
              ],
            ),
          )
              : lcvm.numListas == 0
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Nenhuma lista de compras",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "Clique no botão + para criar uma nova lista",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: lcvm.numListas,
            itemBuilder: (BuildContext ctx, int idx) {
              return itemLista(lcvm.getAt(idx));
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _mostrarDialogoLista(context),
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget itemLista(ListaCompra lista) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: lista.comprada,
          onChanged: (value) {
            lcvm.marcarComoComprada(lista, value ?? false);
          },
        ),
        title: Text(
          lista.nome,
          style: TextStyle(
            decoration: lista.comprada ? TextDecoration.lineThrough : null,
            color: lista.comprada ? Colors.grey : null,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => ItemCompraViewModel(),
                child: TelaListaCompra(lista: lista),
              ),
            ),
          );
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _mostrarDialogoLista(context, lista: lista),
              icon: Icon(Icons.edit, color: Colors.blue),
            ),
            IconButton(
              onPressed: () => _confirmarRemocao(lista),
              icon: Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarRemocao(ListaCompra lista) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar Remoção"),
        content: Text("Deseja remover a lista '${lista.nome}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              lcvm.remover(lista);
              Navigator.pop(context);
            },
            child: Text("Remover"),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoLista(BuildContext context, {ListaCompra? lista}) {
    if (lista != null) {
      lcvm.editar(lista);
    } else {
      lcvm.limparCampos();
    }

    // tipos de lista disponíveis
    final List<String> tiposLista = [
      'Supermercado',
      'Farmácia',
      'Loja de Utilidades',
      'Loja de Ferramentas'
    ];
    String? tipoSelecionado = lista?.tipo ?? tiposLista[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(lista == null ? "Nova Lista" : "Editar Lista"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: lcvm.ctrlNome,
                  decoration: InputDecoration(
                    labelText: "Nome da Lista",
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                SizedBox(height: 16),
                DropdownButton<String>(
                  value: tipoSelecionado,
                  items: tiposLista.map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (String? novoTipo) {
                    setState(() {
                      tipoSelecionado = novoTipo;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  lcvm.cancelar();
                  Navigator.pop(context);
                },
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  if (lcvm.validarNome(lcvm.ctrlNome.text) == null) {
                    lcvm.confirmar(tipo: tipoSelecionado!);
                    Navigator.pop(context);
                  }
                },
                child: Text("Salvar"),
              ),
            ],
          );
        },
      ),
    );
  }
}