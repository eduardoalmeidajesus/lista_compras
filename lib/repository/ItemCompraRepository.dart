import 'package:lista_compras/model/ItemCompra.dart';
import 'package:lista_compras/service/ItemCompraService.dart';
import 'package:lista_compras/service/impl/ItemCompraBDService.dart';

class ItemCompraRepository {
  late ItemCompraService _service;

  static ItemCompraRepository? _instance;

  ItemCompraRepository._internal() {
    _service = ItemCompraBDService();
  }

  static Future<ItemCompraRepository> getInstance() async {
    if (_instance == null) {
      _instance = ItemCompraRepository._internal();
      await _instance!._service.connect();
    }
    return _instance!;
  }

  Future<List<ItemCompra>> getByListaId(int listaId) async {
    return await _service.getByListaId(listaId);
  }

  Future<List<ItemCompra>> getBySetorId(int listaId, int setorId) async {
    return await _service.getBySetorId(listaId, setorId);
  }

  Future<void> insert(ItemCompra novo) async {
    await _service.insert(novo);
  }

  Future<void> update(ItemCompra item) async {
    await _service.update(item);
  }

  Future<void> remove(ItemCompra item) async {
    await _service.remove(item);
  }
}