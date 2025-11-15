import 'base_repository.dart';

class AccountRepository extends BaseRepository {
  Future<List<Map<String, dynamic>>> fetchAccounts() async {
    return await fetchAll(
      'account',
    ); // Usa il metodo generico di BaseRepository
  }

  Future<void> saveAccount(
    Map<String, dynamic>? account,
    String name,
    double balance,
  ) async {
    if (account != null) {
      await update(
        'account',
        {'name': name, 'balance': balance},
        'id = ?',
        [account['id']],
      );
    } else {
      await insert('account', {'name': name, 'balance': balance});
    }
  }

  Future<void> deleteAccount(int id) async {
    await delete('account', 'id = ?', [id]);
  }
}
