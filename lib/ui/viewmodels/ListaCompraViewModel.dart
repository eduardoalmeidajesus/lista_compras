import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lista_compras/model/ListaCompra.dart';
import 'package:lista_compras/repository/ListaCompraRepository.dart';

class ListaCompraViewModel extends ChangeNotifier {
  final _snackbarController = StreamController<String>.broadcast();
  Stream<String> get errorStream => _snackbarController.stream;

  late final ListaCompraRepository _repo;
  bool _conectado = false;

  TextEditingController ctrlNome = TextEditingController();
  ListaCompra? edicao;

  Future<String> conectar() async {
    if (_conectado) return "Já conectado";

    try {
      _repo = await ListaCompraRepository.getInstance();
      await _repo.getAll();
      _conectado = true;
      return "Dados carregados";
    } catch (e) {
      _snackbarController.sink.add("Erro ao conectar: $e");
      rethrow;
    }
  }

  String? validarNome(String? nome) {
    if (nome == null || nome.length < 2) {
      return "Nome deve ter ao menos 2 caracteres";
    }
    return null;
  }

  void confirmar({required String tipo}) async {
    try {
      if (edicao == null) {
        ListaCompra nova = ListaCompra(nome: ctrlNome.text, tipo: tipo);
        await _repo.insert(nova);
      } else {
        edicao!.nome = ctrlNome.text;
        edicao!.tipo = tipo;
        await _repo.update(edicao!);
      }
      limparCampos();
      await _repo.getAll();
      notifyListeners();
    } catch (e) {
      _snackbarController.sink.add("Erro ao salvar lista: $e");
    }
  }

  void limparCampos() {
    ctrlNome.text = "";
    edicao = null;
  }

  void cancelar() {
    limparCampos();
    notifyListeners();
  }

  int get numListas => _repo.getNumListas();
  ListaCompra getAt(int idx) {
    return _repo.getAt(idx);
  }

  void remover(ListaCompra lista) async {
    try {
      await _repo.remove(lista);
      await _repo.getAll();
      notifyListeners();
    } catch (e) {
      _snackbarController.sink.add("Erro ao remover lista: $e");
    }
  }

  void editar(ListaCompra lista) {
    edicao = lista;
    ctrlNome.text = lista.nome;
    notifyListeners();
  }

  void marcarComoComprada(ListaCompra lista, bool comprada) async {
    try {
      lista.comprada = comprada;
      await _repo.update(lista);
      await _repo.getAll();
      notifyListeners();
    } catch (e) {
      _snackbarController.sink.add("Erro ao marcar lista como comprada: $e");
    }
  }

  bool get editando => edicao != null;

  @override
  void dispose() {
    _snackbarController.close();
    super.dispose();
  }
}