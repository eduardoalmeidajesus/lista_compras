import 'package:lista_compras/model/ItemCompra.dart';
import 'package:lista_compras/service/ItemCompraService.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ItemCompraBDService extends ItemCompraService {
  late Database _banco;
  bool _conectado = false;

  @override
  Future<void> connect() async {
    if (_conectado) return;

    _banco = await openDatabase(
      join(await getDatabasesPath(), "listas_compras.db"),
      version: 1,
    );
    _conectado = true;
  }

  @override
  Future<List<ItemCompra>> getByListaId(int listaId) async {
    if (!_conectado) await connect();

    try {
      List<Map> maps = await _banco.rawQuery('''
        SELECT ic.*, s.nome as setorNome 
        FROM item_compra ic 
        LEFT JOIN setor s ON ic.setorId = s.id 
        WHERE ic.listaCompraId = ?
        ORDER BY ic.comprado, s.nome, ic.nome
      ''', [listaId]);

      return maps.map((map) {
        var item = ItemCompra.fromJson(Map<String, dynamic>.from(map));
        item.setorNome = map['setorNome'];
        return item;
      }).toList();
    } catch (e) {
      print("Erro ao buscar itens por lista: $e");
      return [];
    }
  }

  @override
  Future<List<ItemCompra>> getBySetorId(int listaId, int setorId) async {
    if (!_conectado) await connect();

    try {
      List<Map> maps = await _banco.rawQuery('''
        SELECT ic.*, s.nome as setorNome 
        FROM item_compra ic 
        LEFT JOIN setor s ON ic.setorId = s.id 
        WHERE ic.listaCompraId = ? AND ic.setorId = ?
        ORDER BY ic.comprado, ic.nome
      ''', [listaId, setorId]);

      return maps.map((map) {
        var item = ItemCompra.fromJson(Map<String, dynamic>.from(map));
        item.setorNome = map['setorNome'];
        return item;
      }).toList();
    } catch (e) {
      print("Erro ao buscar itens por setor: $e");
      return [];
    }
  }

  @override
  Future insert(ItemCompra novo) async {
    if (!_conectado) await connect();

    try {
      int id = await _banco.insert("item_compra", novo.toJson());
      novo.id = id;
    } catch (e) {
      print("Erro ao inserir item: $e");
      rethrow;
    }
  }

  @override
  Future remove(ItemCompra item) async {
    if (!_conectado) await connect();

    await _banco.delete("item_compra", where: "id = ?", whereArgs: [item.id]);
  }

  @override
  Future update(ItemCompra item) async {
    if (!_conectado) await connect();

    await _banco.update("item_compra", item.toJson(), where: "id = ?", whereArgs: [item.id]);
  }
}