import 'package:lista_compras/model/Setor.dart';
import 'package:lista_compras/service/SetorService.dart';
import 'package:lista_compras/service/impl/SetorBDService.dart';

class SetorRepository {
  late SetorService _service;
  List<Setor>? _cache;

  static SetorRepository? _instance;

  SetorRepository._internal() {
    _service = SetorBDService();
  }

  static Future<SetorRepository> getInstance() async {
    if (_instance == null) {
      _instance = SetorRepository._internal();
      await _instance!._service.connect();
    }
    return _instance!;
  }

  factory SetorRepository.create() {
    return SetorRepository._internal();
  }

  Future<void> connect() async => await _service.connect();

  Future<List<Setor>> getAll() async {
    _cache = await _service.getAll();
    return _cache!;
  }

  Future<List<Setor>> getByTipoLista(String tipoLista) async {
    return await _service.getByTipoLista(tipoLista);
  }

  Future<void> insert(Setor novo) async {
    await _service.insert(novo);
    _cache?.add(novo);
    _cache?.sort((a, b) => a.nome.compareTo(b.nome));
  }

  Future<void> remove(Setor setor) async {
    await _service.remove(setor);
    _cache?.removeWhere((s) => s.id == setor.id);
  }

  Setor getAt(int pos) {
    if (_cache == null || pos >= _cache!.length) {
      throw Exception("Posição inválida");
    }
    return _cache![pos];
  }

  int getNumSetores() => _cache?.length ?? 0;

  Future<Setor> getById(int id) async {
    if (_cache != null) {
      try {
        return _cache!.firstWhere((s) => s.id == id);
      } catch (_) {}
    }
    await getAll();
    return _cache!.firstWhere((s) => s.id == id);
  }
}
