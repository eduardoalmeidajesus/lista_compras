import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lista_compras/model/Setor.dart';
import 'package:lista_compras/repository/SetorRepository.dart';

class SetorViewModel extends ChangeNotifier {
  final _snackbarController = StreamController<String>.broadcast();
  Stream<String> get errorStream => _snackbarController.stream;

  late final SetorRepository _repo;
  bool _conectado = false;

  TextEditingController ctrlNome = TextEditingController();
  Setor? edicao;

  final List<String> tiposLista = [
    'Supermercado',
    'Farmácia',
    'Loja de Utilidades',
    'Loja de Ferramentas'
  ];

  Future<String> conectar() async {
    if (_conectado) return "Já conectado";
    try {
      _repo = await SetorRepository.getInstance();
      await _repo.getAll();
      _conectado = true;
      return "Dados carregados";
    } catch (e) {
      _snackbarController.sink.add("Erro ao conectar: $e");
      rethrow;
    }
  }

  String? validarNome(String? nome) {
    if (nome == null || nome.trim().length < 2) {
      return "Nome deve ter ao menos 2 caracteres";
    }
    return null;
  }

  void confirmar({required String tipoLista}) async {
    try {
      if (validarNome(ctrlNome.text) != null) {
        _snackbarController.sink.add("Nome inválido");
        return;
      }

      if (edicao == null) {
        await _repo.insert(Setor(nome: ctrlNome.text, tipoLista: tipoLista));
      } else {
        await _repo.remove(edicao!);
        await _repo.insert(Setor(
          id: edicao!.id,
          nome: ctrlNome.text,
          tipoLista: tipoLista,
        ));
      }

      await _repo.getAll();
      limparCampos();
      notifyListeners();
    } catch (e) {
      _snackbarController.sink.add("Erro ao salvar setor: $e");
    }
  }

  void limparCampos() {
    ctrlNome.clear();
    edicao = null;
  }

  void cancelar() {
    limparCampos();
    notifyListeners();
  }

  int get numSetores => _repo.getNumSetores();

  Setor getAt(int idx) => _repo.getAt(idx);

  Future<List<Setor>> getByTipoLista(String tipoLista) async {
    try {
      return await _repo.getByTipoLista(tipoLista);
    } catch (e) {
      _snackbarController.sink.add("Erro ao buscar setores por tipo: $e");
      return [];
    }
  }

  void remover(Setor setor) async {
    try {
      await _repo.remove(setor);
      await _repo.getAll();
      notifyListeners();
    } catch (e) {
      _snackbarController.sink.add("Erro ao remover setor: $e");
    }
  }

  void editar(Setor setor) {
    edicao = setor;
    ctrlNome.text = setor.nome;
    notifyListeners();
  }

  @override
  void dispose() {
    _snackbarController.close();
    super.dispose();
  }
}
