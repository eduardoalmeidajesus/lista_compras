import '../model/ListaCompra.dart';

abstract class ListaCompraService {
  Future<void> connect();
  Future update(ListaCompra lista);
  Future<ListaCompra> getById(int id);
  Future<List<ListaCompra>> getAll();
  Future insert(ListaCompra novo);
  Future remove(ListaCompra lista);
  Future<int> numListas();
  Future<ListaCompra> getAt(int idx);
}