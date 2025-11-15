import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

abstract class BaseRepository {
  Future<Database> get db async => await DatabaseHelper.instance.database;

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final database = await db;
    return await database.insert(table, data);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final database = await db;
    return await database.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final database = await db;
    return await database.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> fetchAll(String table) async {
    final database = await db;
    return await database.query(table);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String query, [
    List<dynamic> args = const [],
  ]) async {
    final database = await db;
    return await database.rawQuery(query, args);
  }

  String typeToString(TransactionType type) {
    return type == TransactionType.entrata ? "entrata" : "uscita";
  }
}
