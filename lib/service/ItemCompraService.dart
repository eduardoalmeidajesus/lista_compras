import '../model/ItemCompra.dart';

abstract class ItemCompraService {
  Future<void> connect();
  Future<List<ItemCompra>> getByListaId(int listaId);
  Future insert(ItemCompra novo);
  Future update(ItemCompra item);
  Future remove(ItemCompra item);
  Future<List<ItemCompra>> getBySetorId(int listaId, int setorId);
}