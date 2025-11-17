import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../repositories/account_repository.dart';

class AccountModal extends StatefulWidget {
  final Map<String, dynamic>? account;
  final VoidCallback onAccountUpdated;

  const AccountModal({super.key, required this.onAccountUpdated, this.account});

  static Future<void> show(
    BuildContext context, {
    Map<String, dynamic>? account,
    required VoidCallback onAccountUpdated,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return AccountModal(
          account: account,
          onAccountUpdated: onAccountUpdated,
        );
      },
    );
  }

  @override
  State<AccountModal> createState() => _AccountModalState();
}

class _AccountModalState extends State<AccountModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool get isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      balanceController.text = widget.account!['balance'].toString();
      nameController.text = widget.account!['name'] ?? '';
    }
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    double balance = double.parse(sanitizeBalance(balanceController.text));

    await AccountRepository().saveAccount(
      widget.account,
      nameController.text,
      balance,
    );
    widget.onAccountUpdated();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _deleteAccount() async {
    if (!isEditing) return;
    await AccountRepository().deleteAccount(widget.account!['id']);
    widget.onAccountUpdated();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Modifica conto' : 'Aggiungi conto'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SizedBox(
            width:
                MediaQuery.of(context).size.width * 0.8, // Riduci la larghezza
            child: Column(
              mainAxisSize: MainAxisSize.min, // Adatta l'altezza al contenuto
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nome'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Il nome è obbligatorio'
                              : null,
                ),
                TextFormField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  ],
                  decoration: InputDecoration(labelText: 'Saldo iniziale'),
                  validator:
                      (value) =>
                          isValidNumber(sanitizeBalance(value ?? ''))
                              ? null
                              : 'Inserisci un numero valido',
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (isEditing)
          TextButton(
            onPressed: () async {
              final bool? conferma = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Conferma eliminazione'),
                    content: Text(
                      'Sei sicuro di voler eliminare questo conto?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Annulla'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Elimina',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (conferma == true) {
                await _deleteAccount();
              }
            },
            child: Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ElevatedButton(onPressed: _saveAccount, child: Text('Salva')),
      ],
    );
  }
}
