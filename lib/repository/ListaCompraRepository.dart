import 'package:lista_compras/model/ListaCompra.dart';
import 'package:lista_compras/service/ListaCompraService.dart';
import 'package:lista_compras/service/impl/ListaCompraBDService.dart';

class ListaCompraRepository {
  late ListaCompraService _service;
  List<ListaCompra>? _cache;

  static ListaCompraRepository? _instance;

  ListaCompraRepository._internal() {
    _service = ListaCompraBDService();
  }

  static Future<ListaCompraRepository> getInstance() async {
    if (_instance == null) {
      _instance = ListaCompraRepository._internal();
      await _instance!._service.connect();
    }
    return _instance!;
  }

  Future<List<ListaCompra>> getAll() async {
    try {
      _cache = await _service.getAll();
      return _cache!;
    } catch (e) {
      print("Erro ao carregar listas: $e");
      _cache = [];
      return _cache!;
    }
  }

  Future<ListaCompra> getById(int id) async {
    if (_cache != null) {
      try {
        return _cache!.firstWhere((lista) => lista.id == id);
      } catch (e) {
      }
    }
    await getAll();
    return _cache!.firstWhere((lista) => lista.id == id);
  }

  Future<void> insert(ListaCompra nova) async {
    try {
      print("Repositório: Inserindo lista ${nova.nome}");
      await _service.insert(nova);
      _cache!.add(nova);
      _cache!.sort((a, b) => a.nome.compareTo(b.nome));
      print("Repositório: Lista inserida com sucesso. Cache agora tem ${_cache!.length} itens");
    } catch (e) {
      print("Repositório: Erro ao inserir lista: $e");
      rethrow;
    }
  }

  Future<void> update(ListaCompra lista) async {
    await _service.update(lista);
    int index = _cache!.indexWhere((l) => l.id == lista.id);
    if (index >= 0) {
      _cache![index] = lista;
    }
    _cache!.sort((a, b) => a.nome.compareTo(b.nome));
  }

  Future<void> remove(ListaCompra lista) async {
    await _service.remove(lista);
    _cache!.removeWhere((l) => l.id == lista.id);
  }

  ListaCompra getAt(int pos) {
    if (pos >= 0 && pos < _cache!.length) return _cache![pos];
    throw Exception("Posição inválida");
  }

  int getNumListas() {
    return _cache?.length ?? 0;
  }
}