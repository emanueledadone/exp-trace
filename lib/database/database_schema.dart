import 'package:exp_trace/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseSchema {
  static void createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE account(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL
      )
    ''');
    await db.execute('''
    CREATE TABLE macrocategory(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      type INTEGER NOT NULL CHECK (type IN (0, 1)),
      icon TEXT,
      backgroundColor TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE category(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      macro_category_id INTEGER NOT NULL,
      type INTEGER NOT NULL CHECK (type IN (0, 1)),
      FOREIGN KEY (macro_category_id) REFERENCES macrocategory(id)
    )
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
    )
  ''');

    await db.execute('''
    CREATE TABLE budget (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category_id INTEGER NOT NULL,
      amount REAL NOT NULL,
      period TEXT NOT NULL CHECK (period IN ('mensile', 'annuale')),
      FOREIGN KEY (category_id) REFERENCES category(id)
    )
  ''');

    // Inserimento dati predefiniti
    await db.insert('macrocategory', {
      'name': 'Casa',
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('macrocategory', {
      'name': 'Bollette',
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('macrocategory', {
      'name': 'Spesa',
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('macrocategory', {
      'name': 'Auto',
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('macrocategory', {
      'name': 'Risparmio',
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('macrocategory', {
      'name': 'Spese personali',
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('macrocategory', {
      'name': 'Extra',
      'type': toInt(TransactionType.uscita),
    });

    await db.insert('macrocategory', {
      'name': 'Reddito',
      'type': toInt(TransactionType.entrata),
    });
    await db.insert('macrocategory', {
      'name': 'Risparmi',
      'type': toInt(TransactionType.entrata),
    });

    // Inserimento categorie per ogni macro categoria
    await db.insert('category', {
      'name': 'Mutuo',
      'macro_category_id': 1,
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('category', {
      'name': 'Assicurazione Casa',
      'macro_category_id': 1,
      'type': toInt(TransactionType.uscita),
    });

    await db.insert('category', {
      'name': 'Gas',
      'macro_category_id': 2,
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('category', {
      'name': 'Luce',
      'macro_category_id': 2,
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('category', {
      'name': 'Acqua',
      'macro_category_id': 2,
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('category', {
      'name': 'Internet',
      'macro_category_id': 2,
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('category', {
      'name': 'SIM',
      'macro_category_id': 2,
      'type': toInt(TransactionType.uscita),
    });

    await db.insert('category', {
      'name': 'Alimentare',
      'macro_category_id': 3,
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('category', {
      'name': 'Altro',
      'macro_category_id': 3,
      'type': toInt(TransactionType.uscita),
    });

    await db.insert('category', {
      'name': 'Assicurazione Auto',
      'macro_category_id': 4,
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('category', {
      'name': 'Carburante',
      'macro_category_id': 4,
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('category', {
      'name': 'Bollo',
      'macro_category_id': 4,
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('category', {
      'name': 'Manutenzione',
      'macro_category_id': 4,
      'type': toInt(TransactionType.uscita),
    });

    await db.insert('category', {
      'name': 'Uscire',
      'macro_category_id': 6,
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('category', {
      'name': 'Vestiti',
      'macro_category_id': 6,
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('category', {
      'name': 'Viaggi',
      'macro_category_id': 6,
      'type': toInt(TransactionType.uscita),
    });
    await db.insert('category', {
      'name': 'Abbonamenti',
      'macro_category_id': 6,
      'type': toInt(TransactionType.uscita),
    });

    await db.insert('category', {
      'name': 'Regali',
      'macro_category_id': 7,
      'type': toInt(TransactionType.uscita),
    });

    await db.insert('category', {
      'name': 'Salario',
      'macro_category_id': 8,
      'type': toInt(TransactionType.entrata),
    });
    await db.insert('category', {
      'name': 'Poste',
      'macro_category_id': 9,
      'type': toInt(TransactionType.entrata),
    });
    await db.insert('category', {
      'name': 'Satispay',
      'macro_category_id': 9,
      'type': toInt(TransactionType.entrata),
    });

    await db.execute('''
    CREATE TABLE IF NOT EXISTS steps (
      date TEXT PRIMARY KEY,
      step_count INTEGER,
      previous_step_count INTEGER
    )
  ''');
  }
}
