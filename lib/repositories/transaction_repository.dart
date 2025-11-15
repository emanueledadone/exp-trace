import 'package:exp_trace/database/database_helper.dart';

import 'base_repository.dart';

class TransactionRepository extends BaseRepository {
  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    return await fetchAll(
      'transactions',
    ); // Usa il metodo generico di BaseRepository
  }

  Future<void> saveTransaction(
    Map<String, dynamic>? transaction,
    int categoryId,
    int accountId,
    double amount,
    String notes,
    String date,
  ) async {
    if (transaction != null) {
      await update(
        'transactions',
        {
          'account_id': accountId,
          'category_id': categoryId,
          'amount': amount,
          'notes': notes,
          'date': date,
        },
        'id = ?',
        [transaction['id']],
      );
    } else {
      await insert('transactions', {
        'account_id': accountId,
        'category_id': categoryId,
        'amount': amount,
        'notes': notes,
        'date': date,
      });
    }
  }

  Future<void> deleteTransaction(int id) async {
    await delete('transactions', 'id = ?', [id]);
  }

  Future<List<Map<String, dynamic>>> fetchFilteredTransactions({
    required TransactionType type,
    String? year,
    String? month,
    int? macroCategoryId,
    int? categoryId,
  }) async {
    List<String> conditions = [];
    List<dynamic> args = [];

    conditions.add("category.type = ?");
    args.add(toInt(type));
    if (year != null) {
      conditions.add("strftime('%Y', transactions.date) = ?");
      args.add(year);
    }
    if (month != null) {
      conditions.add("strftime('%m', transactions.date) = ?");
      args.add(month.padLeft(2, '0'));
    }
    if (macroCategoryId != null) {
      conditions.add("category.macro_category_id = ?");
      args.add(macroCategoryId);
    }
    if (categoryId != null) {
      conditions.add("transactions.category_id = ?");
      args.add(categoryId);
    }

    String whereClause =
        conditions.isNotEmpty ? "WHERE ${conditions.join(' AND ')}" : "";

    return await rawQuery('''
    SELECT transactions.id, transactions.amount, transactions.notes, transactions.date, 
           category.id as category_id, category.name as category, 
           category.macro_category_id,
           macrocategory.icon,
           macrocategory.backgroundColor,
           account.id as account_id, account.name as account,category.type
    FROM transactions 
    INNER JOIN category ON transactions.category_id = category.id
    left JOIN macrocategory ON macrocategory.id = category.macro_category_id
    INNER JOIN account ON transactions.account_id = account.id
    $whereClause
    ORDER BY transactions.date DESC
    ''', args);
  }
}
