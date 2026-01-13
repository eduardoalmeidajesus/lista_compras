import 'package:lista_compras/model/Setor.dart';
import 'package:lista_compras/service/SetorService.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SetorBDService extends SetorService {
  late Database _banco;
  bool _conectado = false;

  @override
  Future<void> connect() async {
    if (_conectado) return;

    _banco = await openDatabase(
      join(await getDatabasesPath(), "listas_compras.db"),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE setor (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            tipoLista TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE setor ADD COLUMN tipoLista TEXT DEFAULT "Supermercado"');
        }
      },
    );
    _conectado = true;
  }

  @override
  Future<List<Setor>> getAll() async {
    if (!_conectado) await connect();

    final maps = await _banco.query("setor", orderBy: "nome");
    return maps.map((m) => Setor.fromJson(Map<String, dynamic>.from(m))).toList();
  }

  @override
  Future<List<Setor>> getByTipoLista(String tipoLista) async {
    if (!_conectado) await connect();

    final maps = await _banco.query(
      "setor",
      where: "tipoLista = ?",
      whereArgs: [tipoLista],
      orderBy: "nome",
    );
    return maps.map((m) => Setor.fromJson(Map<String, dynamic>.from(m))).toList();
  }

  @override
  Future<Setor> getAt(int idx) async {
    if (!_conectado) await connect();

    final maps = await _banco.query("setor", orderBy: "nome", offset: idx, limit: 1);
    if (maps.isEmpty) throw Exception("Setor não encontrado");
    return Setor.fromJson(Map<String, dynamic>.from(maps.first));
  }

  @override
  Future<Setor> getById(int id) async {
    if (!_conectado) await connect();

    final maps = await _banco.query("setor", where: "id = ?", whereArgs: [id]);
    if (maps.isEmpty) throw Exception("Setor não encontrado");
    return Setor.fromJson(Map<String, dynamic>.from(maps.first));
  }

  @override
  Future insert(Setor novo) async {
    if (!_conectado) await connect();
    final id = await _banco.insert("setor", novo.toJson());
    novo.id = id;
  }

  @override
  Future<int> numSetores() async {
    if (!_conectado) await connect();
    final maps = await _banco.rawQuery("SELECT COUNT(*) as count FROM setor");
    return maps.first["count"] as int;
  }

  @override
  Future remove(Setor setor) async {
    if (!_conectado) await connect();
    await _banco.delete("setor", where: "id = ?", whereArgs: [setor.id]);
  }
}
