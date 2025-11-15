import 'package:exp_trace/database/database_helper.dart';

import 'base_repository.dart';

class CategoryRepository extends BaseRepository {
  Future<List<Map<String, dynamic>>> fetchCategories(
    TransactionType type,
  ) async {
    return await rawQuery(
      '''
    SELECT category.id, category.name, macrocategory.name AS macro_category, category.type,
          category.macro_category_id
    FROM category
    INNER JOIN macrocategory ON category.macro_category_id = macrocategory.id
    WHERE category.type = ?
  ''',
      [toInt(type)],
    );
  }

  Future<void> saveCategory(
    Map<String, dynamic>? category,
    String name,
    int macroCategoryId,
    TransactionType type,
  ) async {
    if (category != null) {
      await update(
        'category',
        {
          'name': name,
          'macro_category_id': macroCategoryId,
          'type': toInt(type),
        },
        'id = ?',
        [category['id']],
      );
    } else {
      await insert('category', {
        'name': name,
        'macro_category_id': macroCategoryId,
        'type': toInt(type),
      });
    }
  }

  Future<void> deleteCategory(int id) async {
    final database = await db;

    await database.transaction((txn) async {
      await txn.delete('budget', where: 'category_id = ?', whereArgs: [id]);
      await txn.update(
        'transactions',
        {'category_id': null},
        where: 'category_id = ?',
        whereArgs: [id],
      );
      await txn.delete('category', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<Map<String, dynamic>>> fetchCategoriesWithoutBudget(
    String period,
  ) async {
    return await rawQuery(
      '''
    SELECT c.id, c.name
    FROM category c
    LEFT JOIN budget b ON c.id = b.category_id AND b.period = ?
    WHERE c.type = ${toInt(TransactionType.uscita)} AND b.category_id IS NULL
    GROUP BY c.id
    ''',
      [period],
    );
  }
}
