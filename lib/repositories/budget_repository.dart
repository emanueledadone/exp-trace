import 'package:exp_trace/database/database_helper.dart';

import 'base_repository.dart';

class BudgetRepository extends BaseRepository {
  Future<List<Map<String, dynamic>>> fetchBudgets() async {
    return await fetchAll('budget'); // Usa il metodo generico di BaseRepository
  }

  Future<void> saveBudget(
    Map<String, dynamic>? budget,
    int categoryId,
    double amount,
    String period,
  ) async {
    if (budget != null) {
      await update(
        'budget',
        {'category_id': categoryId, 'amount': amount, 'period': period},
        'id = ?',
        [budget['id']],
      );
    } else {
      await insert('budget', {
        'category_id': categoryId,
        'amount': amount,
        'period': period,
      });
    }
  }

  Future<void> deleteBudget(int id) async {
    await delete('budget', 'id = ?', [id]);
  }

  Future<List<Map<String, dynamic>>> fetchMonthlyBudget(
    String month,
    String year,
  ) async {
    return await rawQuery('''
    SELECT mc.id, mc.name, mc.icon, 
            mc.backgroundColor,
           b.period,
           IFNULL(SUM(b.amount), 0) AS budget
    FROM macrocategory mc
    inner JOIN category c ON mc.id = c.macro_category_id
    INNER JOIN budget b ON c.id = b.category_id AND b.period = 'mensile'
    WHERE mc.type = ${toInt(TransactionType.uscita)}
    GROUP BY mc.id
  ''');
  }

  Future<List<Map<String, dynamic>>> fetchAnnualBudget(String year) async {
    return await rawQuery('''
    SELECT mc.id, mc.name, mc.icon, 
            mc.backgroundColor,
           b.period,
           IFNULL(SUM(b.amount), 0) AS budget
    FROM macrocategory mc
    inner JOIN category c ON mc.id = c.macro_category_id
    INNER JOIN budget b ON c.id = b.category_id AND b.period = 'annuale' 
    WHERE mc.type = ${toInt(TransactionType.uscita)}
    GROUP BY mc.id
  ''');
  }

  Future<List<Map<String, dynamic>>> fetchCategoryDetails(
    String period,
    String? month,
    String? year,
  ) async {
    if (month != null) {
      month = month.padLeft(2, '0');
    }
    List<dynamic> args = [];

    if (year != null) {
      args.add(year);
    }
    if (month != null) {
      String paddedMonth = month.padLeft(2, '0');
      args.add(paddedMonth);
    }
    args.add(period);
    args.add(period);
    return await rawQuery('''
   SELECT 
    c.id, 
    c.name, 
    IFNULL(SUM(t.amount), 0) AS spent,
    c.macro_category_id,
    b.id AS budget_id,
    b.period,
    IFNULL(b.amount, 0) AS budget
FROM category c
left JOIN transactions t 
    ON c.id = t.category_id 
    ${year != null ? "AND strftime('%Y', t.date) = ?" : ""}
${month != null ? "AND strftime('%m', t.date) = ?" : ""}

left JOIN (
     SELECT id, category_id, period, SUM(amount) AS amount
    FROM budget
    WHERE period = ?
    GROUP BY category_id, period
) b ON c.id = b.category_id 
    AND b.period = ?
WHERE c.type = ${toInt(TransactionType.uscita)}
GROUP BY c.id
    ''', args);
  }

  Future<double> getBudget() async {
    final result = await rawQuery('''
    SELECT IFNULL(SUM(b.amount), 0) AS budget
    FROM budget b 
    WHERE b.period = 'mensile' ''', []);

    if (result.isNotEmpty && result.first['budget'] is num) {
      return (result.first['budget'] as num).toDouble(); // Convertire in double
    }
    return 0.0;
  }
}
