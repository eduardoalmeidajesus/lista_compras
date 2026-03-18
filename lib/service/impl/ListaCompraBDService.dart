import 'package:lista_compras/model/ListaCompra.dart';
import 'package:lista_compras/service/ListaCompraService.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ListaCompraBDService extends ListaCompraService {
  late Database _banco;
  bool _conectado = false;

  @override
  Future<void> connect() async {
    if (_conectado) return;

    final databasePath = join(await getDatabasesPath(), "listas_compras.db");
    _banco = await openDatabase(
      databasePath,
      // criar tabela
      onCreate: (db, versao) async {
        await db.execute(
            "CREATE TABLE lista_compra (id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, comprada INTEGER, tipo TEXT)");
        await db.execute(
            "CREATE TABLE setor (id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, tipoLista TEXT)");
        await db.execute(
            "CREATE TABLE item_compra (id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, comprado INTEGER, listaCompraId INTEGER, setorId INTEGER)");

        // setores
        await db.insert('setor', {'nome': 'Limpeza', 'tipoLista': 'Supermercado'});
        await db.insert('setor', {'nome': 'Higiene', 'tipoLista': 'Supermercado'});
        await db.insert('setor', {'nome': 'Frutas e Verduras', 'tipoLista': 'Supermercado'});
        await db.insert('setor', {'nome': 'Carnes', 'tipoLista': 'Supermercado'});
        await db.insert('setor', {'nome': 'Padaria', 'tipoLista': 'Supermercado'});
        await db.insert('setor', {'nome': 'Bebidas', 'tipoLista': 'Supermercado'});
        await db.insert('setor', {'nome': 'Laticínios', 'tipoLista': 'Supermercado'});
        await db.insert('setor', {'nome': 'Grãos e Cereais', 'tipoLista': 'Supermercado'});


        await db.insert('setor', {'nome': 'Medicamentos', 'tipoLista': 'Farmácia'});
        await db.insert('setor', {'nome': 'Higiene Pessoal', 'tipoLista': 'Farmácia'});
        await db.insert('setor', {'nome': 'Cosméticos', 'tipoLista': 'Farmácia'});
        await db.insert('setor', {'nome': 'Primeiros Socorros', 'tipoLista': 'Farmácia'});
        await db.insert('setor', {'nome': 'Vitaminas', 'tipoLista': 'Farmácia'});
        await db.insert('setor', {'nome': 'Cuidados com a Pele', 'tipoLista': 'Farmácia'});


        await db.insert('setor', {'nome': 'Cozinha', 'tipoLista': 'Loja de Utilidades'});
        await db.insert('setor', {'nome': 'Banheiro', 'tipoLista': 'Loja de Utilidades'});
        await db.insert('setor', {'nome': 'Limpeza Doméstica', 'tipoLista': 'Loja de Utilidades'});
        await db.insert('setor', {'nome': 'Organização', 'tipoLista': 'Loja de Utilidades'});
        await db.insert('setor', {'nome': 'Decoração', 'tipoLista': 'Loja de Utilidades'});
        await db.insert('setor', {'nome': 'Jardim', 'tipoLista': 'Loja de Utilidades'});


        await db.insert('setor', {'nome': 'Ferramentas Manuais', 'tipoLista': 'Loja de Ferramentas'});
        await db.insert('setor', {'nome': 'Ferramentas Elétricas', 'tipoLista': 'Loja de Ferramentas'});
        await db.insert('setor', {'nome': 'Parafusos e Fixadores', 'tipoLista': 'Loja de Ferramentas'});
        await db.insert('setor', {'nome': 'Pintura', 'tipoLista': 'Loja de Ferramentas'});
        await db.insert('setor', {'nome': 'Jardim e Exterior', 'tipoLista': 'Loja de Ferramentas'});
        await db.insert('setor', {'nome': 'Material Elétrico', 'tipoLista': 'Loja de Ferramentas'});
        await db.insert('setor', {'nome': 'Segurança', 'tipoLista': 'Loja de Ferramentas'});
      },
      version: 1,
    );
    _conectado = true;
  }

  @override
  Future<List<ListaCompra>> getAll() async {
    if (!_conectado) await connect();

    try {
      List<Map> maps = await _banco.query("lista_compra", orderBy: "nome");
      return maps.map((map) => ListaCompra.fromJson(Map<String, dynamic>.from(map))).toList();
    } catch (e) {
      print("Erro ao buscar listas: $e");
      return [];
    }
  }

  @override
  Future<ListaCompra> getAt(int idx) async {
    if (!_conectado) await connect();

    List<Map> maps = await _banco.query("lista_compra", orderBy: "nome", offset: idx, limit: 1);
    if (maps.isEmpty) {
      throw Exception("Lista não encontrada");
    }
    return ListaCompra.fromJson(Map<String, dynamic>.from(maps.first));
  }

  @override
  Future<ListaCompra> getById(int id) async {
    if (!_conectado) await connect();

    List<Map> maps = await _banco.query("lista_compra", where: "id = ?", whereArgs: [id]);
    if (maps.isEmpty) {
      throw Exception("Lista não encontrada");
    }
    return ListaCompra.fromJson(Map<String, dynamic>.from(maps.first));
  }

  @override
  Future insert(ListaCompra novo) async {
    if (!_conectado) await connect();

    try {
      print("Inserindo nova lista: ${novo.nome}");
      int id = await _banco.insert("lista_compra", novo.toJson());
      novo.id = id;
      print("Lista inserida com ID: $id");
    } catch (e) {
      print("Erro ao inserir lista: $e");
      rethrow;
    }
  }

  @override
  Future<int> numListas() async {
    if (!_conectado) await connect();

    try {
      List<Map> maps = await _banco.rawQuery("SELECT COUNT(*) as count FROM lista_compra");
      return maps.first["count"] ?? 0;
    } catch (e) {
      print("Erro ao contar listas: $e");
      return 0;
    }
  }

  @override
  Future remove(ListaCompra lista) async {
    if (!_conectado) await connect();

    await _banco.delete("lista_compra", where: "id = ?", whereArgs: [lista.id]);
    await _banco.delete("item_compra", where: "listaCompraId = ?", whereArgs: [lista.id]);
  }

  @override
  Future update(ListaCompra lista) async {
    if (!_conectado) await connect();

    await _banco.update("lista_compra", lista.toJson(), where: "id = ?", whereArgs: [lista.id]);
  }
}