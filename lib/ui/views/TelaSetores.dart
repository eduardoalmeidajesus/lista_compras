import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lista_compras/ui/viewmodels/SetorViewModel.dart';
import 'package:provider/provider.dart';

class TelaSetores extends StatefulWidget {
  const TelaSetores({super.key});

  @override
  State<TelaSetores> createState() => _TelaSetoresState();
}

class _TelaSetoresState extends State<TelaSetores> {
  late SetorViewModel? svm = null;
  late StreamSubscription _errorSubscription;
  late Future<String> _conectado;

  void configurar() async {
    _errorSubscription = svm!.errorStream.listen((msg) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 4)),
      );
    });
  }

  @override
  void dispose() {
    _errorSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (svm == null) {
      svm = Provider.of<SetorViewModel>(context);
      _conectado = svm!.conectar();
      configurar();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Gerenciar Setores"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<String>(
        future: _conectado,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: svm!.numSetores,
                  itemBuilder: (BuildContext ctx, int idx) {
                    return itemSetor(svm!.getAt(idx));
                  },
                ),
              ),
            ],
          )
              : const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoSetor(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget itemSetor(setor) {
    return Card(
      child: ListTile(
        title: Text(setor.nome),
        subtitle: Text("Tipo: ${setor.tipoLista}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _mostrarDialogoSetor(context, setor: setor),
              icon: const Icon(Icons.edit, color: Colors.blue),
            ),
            IconButton(
              onPressed: () => _confirmarRemocao(setor),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarRemocao(setor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar Remoção"),
        content: Text("Deseja remover o setor '${setor.nome}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              svm!.remover(setor);
              Navigator.pop(context);
            },
            child: const Text("Remover"),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoSetor(BuildContext context, {setor}) {
    if (setor != null) {
      svm!.editar(setor);
    } else {
      svm!.limparCampos();
    }

    // tipos de lista disponíveis
    final List<String> tiposLista = [
      'Supermercado',
      'Farmácia',
      'Loja de Utilidades',
      'Loja de Ferramentas',
    ];

    String? tipoSelecionado = setor?.tipoLista ?? tiposLista.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(setor == null ? "Novo Setor" : "Editar Setor"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: svm!.ctrlNome,
                  decoration: const InputDecoration(
                    labelText: "Nome do Setor",
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: tipoSelecionado,
                  decoration: const InputDecoration(
                    labelText: "Tipo de Lista",
                    border: OutlineInputBorder(),
                  ),
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
                  svm!.cancelar();
                  Navigator.pop(context);
                },
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  if (svm!.validarNome(svm!.ctrlNome.text) == null &&
                      tipoSelecionado != null) {
                    svm!.confirmar(tipoLista: tipoSelecionado!);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Selecione um tipo de lista"),
                      ),
                    );
                  }
                },
                child: const Text("Salvar"),
              ),
            ],
          );
        },
      ),
    );
  }
}
