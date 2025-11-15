import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../database/database_helper.dart';
import '../repositories/macro_category_repository.dart';
import '../utils/app_icons.dart'; // Importa la mappa di icone

class MacroCategoryModal extends StatefulWidget {
  final TransactionType type; // 'entrata' o 'uscita'
  final VoidCallback onCategoryUpdated;
  final Map<String, dynamic>? macroCategory;

  const MacroCategoryModal({
    required this.onCategoryUpdated,
    required this.type,
    this.macroCategory,
  });

  static Future<void> show(
    BuildContext context, {
    required TransactionType type,
    required VoidCallback onCategoryUpdated,
    Map<String, dynamic>? macroCategory,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return MacroCategoryModal(
          type: type,
          onCategoryUpdated: onCategoryUpdated,
          macroCategory: macroCategory,
        );
      },
    );
  }

  @override
  _MacroCategoryModalState createState() => _MacroCategoryModalState();
}

class _MacroCategoryModalState extends State<MacroCategoryModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  IconData? selectedIcon;
  Color selectedColor = Colors.white;

  bool get isEditing => widget.macroCategory != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      selectedIcon = AppIcons.iconMapping[widget.macroCategory!['icon']];

      try {
        selectedColor =
            widget.macroCategory!['backgroundColor'] != null
                ? Color(
                  int.parse(
                    widget.macroCategory!['backgroundColor'],
                    radix: 16,
                  ),
                )
                : Colors.white;
      } catch (e) {
        selectedColor = Colors.white;
      }
      nameController.text = widget.macroCategory!['name'] ?? '';
    }
  }

  Future<void> _pickIcon() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Seleziona Icona"),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              children:
                  AppIcons.iconMapping.entries.map((entry) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIcon = entry.value;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(entry.value, size: 40),
                      ),
                    );
                  }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annulla"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickColor() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Seleziona Colore"),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  setState(() {
                    selectedColor = color;
                  });
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    await MacroCategoryRepository().saveMacroCategory(
      widget.macroCategory,
      nameController.text,
      widget.type,
      selectedIcon != null
          ? AppIcons.iconMapping.entries
              .firstWhere((entry) => entry.value == selectedIcon)
              .key
          : null,
      selectedColor.toARGB32().toRadixString(16),
    );
    widget.onCategoryUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Macrocategoria'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Il nome è obbligatorio'
                          : null,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickIcon,
              child: Text("Seleziona Icona"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickColor,
              child: Text("Seleziona Colore"),
            ),
            SizedBox(height: 10),
            if (selectedIcon != null)
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(selectedIcon, color: Colors.white, size: 40),
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
        ElevatedButton(onPressed: _saveCategory, child: const Text("Salva")),
      ],
    );
  }
}
