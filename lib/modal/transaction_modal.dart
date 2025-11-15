import 'package:exp_trace/repositories/category_repository.dart';
import 'package:exp_trace/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../main.dart';
import '../repositories/account_repository.dart';

class TransactionModal extends StatefulWidget {
  final TransactionType type;
  final Map<String, dynamic>? transaction;
  final VoidCallback onTransactionUpdated;

  const TransactionModal({
    super.key,
    required this.type,
    required this.onTransactionUpdated,
    this.transaction,
  });

  static Future<void> show(
    BuildContext context, {
    required TransactionType type,
    Map<String, dynamic>? transaction,
    required VoidCallback onTransactionUpdated,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return TransactionModal(
          transaction: transaction,
          type: type,
          onTransactionUpdated: onTransactionUpdated,
        );
      },
    );
  }

  @override
  State<TransactionModal> createState() => _TransactionModalState();
}

class _TransactionModalState extends State<TransactionModal> {
  final _formKey = GlobalKey<FormState>();
  int? selectedCategory;
  int? selectedAccount;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final AccountRepository accountRepository = AccountRepository();
  String date = "";
  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      selectedCategory = widget.transaction!['category_id'];
      selectedAccount = widget.transaction!['account_id'];
      amountController.text = widget.transaction!['amount'].toString();
      notesController.text = widget.transaction!['notes'] ?? '';

      date = widget.transaction!['date']; // Salva la versione completa
      dateController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime.parse(date)); // Mostra la versione formattata
    } else {
      date = DateTime.now().toIso8601String();
      dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    double amount = double.parse(amountController.text);

    await TransactionRepository().saveTransaction(
      widget.transaction,
      selectedCategory!,
      selectedAccount!,
      amount,
      notesController.text,
      date,
    );
    widget.onTransactionUpdated();
    Navigator.pop(context);
  }

  Future<void> _deleteTransaction() async {
    if (!isEditing) return;
    await TransactionRepository().deleteTransaction(widget.transaction!['id']);
    widget.onTransactionUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final String type =
        widget.type == TransactionType.entrata ? 'Entrata' : 'Uscita';
    return AlertDialog(
      title: Text(isEditing ? "Modifica $type" : "Aggiungi $type"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCategoryDropdown(),
            _buildAccountDropdown(),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Somma'),
              validator:
                  (value) =>
                      isValidNumber(value ?? '')
                          ? null
                          : 'Inserisci un numero valido',
            ),
            TextFormField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            TextFormField(
              controller: dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Data',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annulla"),
        ),
        if (isEditing)
          TextButton(
            onPressed: _deleteTransaction,
            child: const Text("Elimina", style: TextStyle(color: Colors.red)),
          ),
        ElevatedButton(onPressed: _saveTransaction, child: const Text("Salva")),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return FutureBuilder(
      future: CategoryRepository().fetchCategories(widget.type),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        return DropdownButtonFormField(
          decoration: const InputDecoration(labelText: 'Categoria'),
          value: selectedCategory,
          items:
              snapshot.data!.map((category) {
                return DropdownMenuItem(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
          onChanged: (value) => setState(() => selectedCategory = value as int),
          validator:
              (value) => value == null ? 'Seleziona una categoria' : null,
        );
      },
    );
  }

  Widget _buildAccountDropdown() {
    return FutureBuilder(
      future: accountRepository.fetchAccounts(),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        return DropdownButtonFormField(
          decoration: const InputDecoration(labelText: 'Conto'),
          value: selectedAccount,
          items:
              snapshot.data!.map((account) {
                return DropdownMenuItem(
                  value: account['id'],
                  child: Text(account['name']),
                );
              }).toList(),
          onChanged: (value) => setState(() => selectedAccount = value as int),
          validator: (value) => value == null ? 'Seleziona un conto' : null,
        );
      },
    );
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      date = picked.toIso8601String(); // Salva il formato completo
      dateController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(picked); // Mostra il formato formattato
    }
  }
}
