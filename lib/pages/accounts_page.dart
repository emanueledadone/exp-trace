import 'package:flutter/material.dart';
import '../modal/account_modal.dart';
import '../repositories/account_repository.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});
  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final AccountRepository accountRepository = AccountRepository();
  List<Map<String, dynamic>> accounts = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  Future<void> _loadAccounts() async {
    final data = await accountRepository.fetchAccounts();
    setState(() => accounts = data);
  }

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Elenco Conti')),
      body:
          accounts.isEmpty
              ? Center(
                child: Text(
                  'Nessun conto presente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
              : ListView.builder(
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  var account = accounts[index];
                  return ListTile(
                    title: Text(account['name']),
                    subtitle: Text('Saldo: ${account['balance']} €'),
                    onTap:
                        () => AccountModal.show(
                          context,
                          account: account,
                          onAccountUpdated: _loadAccounts,
                        ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => AccountModal.show(context, onAccountUpdated: _loadAccounts),
        child: Icon(Icons.add),
      ),
    );
  }
}
