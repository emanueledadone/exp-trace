import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../database/database_schema.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('accounts.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: DatabaseSchema.createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Transazioni con categorie null se cancello la categoria
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE transactions
        RENAME TO transactions_old;
      ''');

      await db.execute('''
        CREATE TABLE transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id INTEGER,
          account_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          notes TEXT,
          date TEXT NOT NULL,
          FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE SET NULL,
          FOREIGN KEY (account_id) REFERENCES account(id)
        );
      ''');

      await db.execute('''
        INSERT INTO transactions (id, category_id, account_id, amount, notes, date)
        SELECT id, category_id, account_id, amount, notes, date FROM transactions_old;
      ''');

      await db.execute('DROP TABLE transactions_old');

      await db.execute('''
        ALTER TABLE macrocategory ADD COLUMN icon TEXT;
      ''');
      await db.execute('''
        ALTER TABLE macrocategory ADD COLUMN backgroundColor TEXT;
      ''');

      await fixData(db);
    }
  }

  Future<void> cleanOrphanCategoriesAndTransactions(Database db) async {
    await db.transaction((txn) async {
      // Trova le categorie senza macrocategoria
      List<Map<String, dynamic>> orphanCategories = await txn.rawQuery('''
        SELECT c.id FROM category c
        LEFT JOIN macrocategory m ON c.macro_category_id = m.id
        WHERE m.id IS NULL
      ''');

      for (var category in orphanCategories) {
        int categoryId = category['id'];
        await txn.delete(
          'budget',
          where: 'category_id = ?',
          whereArgs: [categoryId],
        );
        await txn.update(
          'transactions',
          {'category_id': null},
          where: 'category_id = ?',
          whereArgs: [categoryId],
        );
        await txn.delete('category', where: 'id = ?', whereArgs: [categoryId]);
      }
    });
  }

  Future<void> fixData(Database db) async {
    await cleanOrphanCategoriesAndTransactions(db);
  }

  Future<void> backupDatabase(String backupPath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'accounts.db');

    final sourceFile = File(path);
    final backupFile = File(backupPath);

    await backupFile.writeAsBytes(await sourceFile.readAsBytes());
  }

  Future<void> restoreDatabase(String backupPath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'accounts.db');

    final backupFile = File(backupPath);
    if (!backupFile.existsSync()) {
      throw Exception("File di backup non trovato!");
    }

    final targetFile = File(path);
    await targetFile.writeAsBytes(await backupFile.readAsBytes());

    // Riaprire il database dopo il ripristino
    _database = await _initDB('accounts.db');
    await fixData(_database!);
  }
}

// Define the enum
// ENTRATE = 0
// USCITE = 1
enum TransactionType { entrata, uscita }

int toInt(TransactionType type) => type.index;
TransactionType fromInt(int value) => TransactionType.values[value];
