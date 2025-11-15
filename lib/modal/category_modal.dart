import 'package:exp_trace/repositories/category_repository.dart';
import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class CategoryModal extends StatefulWidget {
  final TransactionType type; // 'entrata' o 'uscita'
  final List<Map<String, dynamic>> macroCategories;
  final VoidCallback onCategoryUpdated;
  final Map<String, dynamic>? category;

  const CategoryModal({
    super.key,
    required this.onCategoryUpdated,
    required this.macroCategories,
    required this.type,
    this.category,
  });

  static Future<void> show(
    BuildContext context, {
    required TransactionType type,
    required List<Map<String, dynamic>> macroCategories,
    required VoidCallback onCategoryUpdated,
    Map<String, dynamic>? category,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return CategoryModal(
          type: type,
          macroCategories: macroCategories,
          onCategoryUpdated: onCategoryUpdated,
          category: category,
        );
      },
    );
  }

  @override
  _CategoryModalState createState() => _CategoryModalState();
}

class _CategoryModalState extends State<CategoryModal> {
  final _formKey = GlobalKey<FormState>();
  int? selectedMacroCategory;
  final TextEditingController nameController = TextEditingController();
  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      selectedMacroCategory = widget.category!['macro_category_id'];
      nameController.text = widget.category!['name'] ?? '';
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    await CategoryRepository().saveCategory(
      widget.category,
      nameController.text,
      selectedMacroCategory!,
      widget.type,
    );
    widget.onCategoryUpdated();
    Navigator.pop(context);
  }

  Future<void> _deleteCategory() async {
    if (!isEditing) return;
    await CategoryRepository().deleteCategory(widget.category!['id']);
    widget.onCategoryUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Categoria'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: selectedMacroCategory,
              decoration: const InputDecoration(labelText: "Macrocategoria"),
              items:
                  widget.macroCategories.map((macro) {
                    return DropdownMenuItem<int>(
                      value: macro['id'],
                      child: Text(macro['name']),
                    );
                  }).toList(),
              onChanged:
                  (value) => setState(() => selectedMacroCategory = value),
              validator:
                  (value) =>
                      value == null ? 'Seleziona una macrocategoria' : null,
            ),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nome'),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Il nome è obbligatorio'
                          : null,
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
            onPressed: _deleteCategory,
            child: const Text("Elimina", style: TextStyle(color: Colors.red)),
          ),
        ElevatedButton(onPressed: _saveCategory, child: const Text("Salva")),
      ],
    );
  }
}
