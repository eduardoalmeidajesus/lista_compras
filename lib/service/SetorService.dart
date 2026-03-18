import '../model/Setor.dart';

abstract class SetorService {
  Future<void> connect();
  Future<List<Setor>> getAll();
  Future<List<Setor>> getByTipoLista(String tipoLista);
  Future insert(Setor novo);
  Future remove(Setor setor);
  Future<int> numSetores();
  Future<Setor> getAt(int idx);
  Future<Setor> getById(int id);
}