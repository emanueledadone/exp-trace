import 'package:exp_trace/database/database_helper.dart';

import 'base_repository.dart';

class MacroCategoryRepository extends BaseRepository {
  Future<List<Map<String, dynamic>>> fetchMacroCategories(
    TransactionType type,
  ) async {
    return await rawQuery(
      '''
     SELECT id, name, type, icon, backgroundColor
    FROM macrocategory
    WHERE type = ?
  ''',
      [toInt(type)],
    );
  }

  Future<void> saveMacroCategory(
    Map<String, dynamic>? macroCategory,
    String name,
    TransactionType type,
    String? icon,
    String backgroundColor,
  ) async {
    if (macroCategory != null) {
      await update(
        'macrocategory', // Cambiato da 'category' a 'macrocategory'
        {
          'name': name,
          'type': toInt(type),
          'icon': icon, // Aggiunta l'icona
          'backgroundColor': backgroundColor, // Aggiunto il colore di sfondo
        },
        'id = ?',
        [macroCategory['id']],
      );
    } else {
      await insert('macrocategory', {
        'name': name,
        'type': toInt(type),
        'icon': icon,
        'backgroundColor': backgroundColor,
      });
    }
  }

  Future<void> deleteMacroCategory(int id) async {
    final database = await db;

    await database.transaction((txn) async {
      // Trova tutte le categorie associate alla macrocategoria
      List<Map<String, dynamic>> categories = await txn.query(
        'category',
        where: 'macro_category_id = ?',
        whereArgs: [id],
      );

      for (var category in categories) {
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

      // Elimina la macrocategoria
      await txn.delete('macrocategory', where: 'id = ?', whereArgs: [id]);
    });
  }
}
