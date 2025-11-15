import 'package:exp_trace/repositories/budget_repository.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class BudgetModal extends StatefulWidget {
  final Map<String, dynamic>? budget;
  final VoidCallback onBudgetUpdated;
  final List<Map<String, dynamic>> categories;
  final String period;

  const BudgetModal({
    super.key,
    required this.onBudgetUpdated,
    required this.categories,
    required this.period,
    this.budget,
  });

  static Future<void> show(
    BuildContext context, {
    Map<String, dynamic>? budget,
    required String period,
    required VoidCallback onBudgetUpdated,
    required List<Map<String, dynamic>> categories,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return BudgetModal(
          budget: budget,
          period: period,
          onBudgetUpdated: onBudgetUpdated,
          categories: categories,
        );
      },
    );
  }

  @override
  _BudgetModalState createState() => _BudgetModalState();
}

class _BudgetModalState extends State<BudgetModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final Color background = Colors.blueGrey[100]!;
  int? selectedCategory;
  bool get isEditing => widget.budget != null;
  String period = 'mensile';

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      selectedCategory = widget.budget!['category_id'];
      amountController.text = widget.budget!['budget'].toString();
      period = widget.budget!['period'];
    } else {
      period = widget.period;
    }
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    double amount = double.parse(sanitizeBalance(amountController.text));

    await BudgetRepository().saveBudget(
      widget.budget,
      selectedCategory!,
      amount,
      period,
    );
    widget.onBudgetUpdated();
    Navigator.pop(context);
  }

  Future<void> _deleteBudget() async {
    if (!isEditing) return;
    await BudgetRepository().deleteBudget(widget.budget!['id']);
    widget.onBudgetUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Modifica Budget' : 'Aggiungi Budget'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isEditing)
              DropdownButtonFormField<int>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: "Categoria"),
                items:
                    widget.categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                validator:
                    (value) => value == null ? 'Seleziona una categoria' : null,
              ),
            if (isEditing)
              InputDecorator(
                decoration: InputDecoration(
                  labelText: '',
                  fillColor: background,
                  filled: true,
                ),

                child: Text(
                  widget
                      .budget!['category_name'], // il valore che vuoi mostrare
                  style: TextStyle(fontSize: 16), // opzionale
                ),
              ),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Importo"),
              validator:
                  (value) =>
                      isValidNumber(sanitizeBalance(value ?? ''))
                          ? null
                          : 'Inserisci un numero valido',
            ),
            SizedBox(width: 4),
            InputDecorator(
              decoration: InputDecoration(
                labelText: '',
                fillColor: background,
                filled: true,
              ),
              child: Text(
                period, // il valore che vuoi mostrare
                style: TextStyle(fontSize: 16), // opzionale
              ),
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
            onPressed: _deleteBudget,
            child: const Text("Elimina", style: TextStyle(color: Colors.red)),
          ),
        ElevatedButton(onPressed: _saveBudget, child: const Text("Salva")),
      ],
    );
  }
}
