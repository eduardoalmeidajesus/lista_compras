import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lista_compras/model/ItemCompra.dart';
import 'package:lista_compras/model/Setor.dart';
import 'package:lista_compras/repository/ItemCompraRepository.dart';
import 'package:lista_compras/repository/SetorRepository.dart';

class ItemCompraViewModel extends ChangeNotifier {
  final _snackbarController = StreamController<String>.broadcast();
  Stream<String> get errorStream => _snackbarController.stream;

  late final ItemCompraRepository _repo;
  late final SetorRepository _setorRepo;
  bool _conectado = false;

  TextEditingController ctrlNomeItem = TextEditingController();
  Setor? setorSelecionado;
  List<ItemCompra> itens = [];
  int? listaCompraId;

  Future<String> conectar() async {
    if (_conectado) return "Já conectado";

    try {
      _repo = await ItemCompraRepository.getInstance();
      _setorRepo = await SetorRepository.getInstance();
      await _setorRepo.getAll();
      _conectado = true;
      return "Dados carregados";
    } catch (e) {
      _snackbarController.sink.add("Erro ao conectar: $e");
      rethrow;
    }
  }

  Future<void> carregarItens(int listaId) async {
    try {
      listaCompraId = listaId;
      itens = await _repo.getByListaId(listaId);
      notifyListeners();
    } catch (e) {
      _snackbarController.sink.add("Erro ao carregar itens: $e");
    }
  }

  Future<void> carregarItensPorSetor(int listaId, int setorId) async {
    try {
      listaCompraId = listaId;
      itens = await _repo.getBySetorId(listaId, setorId);
      notifyListeners();
    } catch (e) {
      _snackbarController.sink.add("Erro ao carregar itens por setor: $e");
    }
  }

  String? validarNome(String? nome) {
    if (nome == null || nome.length < 2) {
      return "Nome deve ter ao menos 2 caracteres";
    }
    return null;
  }

  void confirmarItem() async {
    try {
      if (setorSelecionado == null) {
        _snackbarController.sink.add("Selecione um setor");
        return;
      }

      ItemCompra novo = ItemCompra(
        nome: ctrlNomeItem.text,
        listaCompraId: listaCompraId!,
        setorId: setorSelecionado!.id!,
      );

      await _repo.insert(novo);
      await carregarItens(listaCompraId!);
      limparCampos();
    } catch (e) {
      _snackbarController.sink.add("Erro ao salvar item: $e");
    }
  }

  void limparCampos() {
    ctrlNomeItem.text = "";
    setorSelecionado = null;
  }

  void marcarComoComprado(ItemCompra item, bool comprado) async {
    try {
      item.comprado = comprado;
      await _repo.update(item);
      await carregarItens(listaCompraId!);
    } catch (e) {
      _snackbarController.sink.add("Erro ao marcar item: $e");
    }
  }

  void removerItem(ItemCompra item) async {
    try {
      await _repo.remove(item);
      await carregarItens(listaCompraId!);
    } catch (e) {
      _snackbarController.sink.add("Erro ao remover item: $e");
    }
  }

  int get quantidadeFaltante {
    return itens.where((item) => !item.comprado).length;
  }

  @override
  void dispose() {
    _snackbarController.close();
    super.dispose();
  }
}