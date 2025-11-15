import 'package:exp_trace/modal/macro_category_modal.dart';
import 'package:exp_trace/repositories/category_repository.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../modal/category_modal.dart';
import '../repositories/macro_category_repository.dart';
import '../utils/app_icons.dart'; // Importa la mappa di icone

class CategoriesPage extends StatefulWidget {
  final TransactionType type; // 'entrata' o 'uscita'

  const CategoriesPage({super.key, required this.type});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> macroCategories = [];

  final TextEditingController macroCategoryController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  int? selectedMacroCategory;

  Future<void> _loadData() async {
    macroCategories = await MacroCategoryRepository().fetchMacroCategories(
      widget.type,
    );
    categories = await CategoryRepository().fetchCategories(widget.type);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == TransactionType.entrata
              ? 'Gestione Entrate'
              : 'Gestione Uscite',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'Macrocategorie',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: macroCategories.length,
                    itemBuilder: (context, index) {
                      var macroCategory = macroCategories[index];
                      IconData? icon =
                          AppIcons.iconMapping[macroCategory['icon']];
                      int? intColor =
                          macroCategory['backgroundColor'] != null
                              ? int.tryParse(
                                macroCategory['backgroundColor'],
                                radix: 16,
                              )
                              : null;
                      Color color =
                          intColor != null
                              ? Color(intColor)
                              : Colors.transparent;

                      Widget title = Text(macroCategory['name']);
                      if (icon != null) {
                        title = Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  icon,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                            Expanded(child: Text(macroCategory['name'])),
                          ],
                        );
                      }
                      return ListTile(
                        title: title,
                        onTap:
                            () => MacroCategoryModal.show(
                              context,
                              macroCategory: macroCategory,
                              type: widget.type,
                              onCategoryUpdated: _loadData,
                            ),
                      );
                    },
                  ),
                ),
                FloatingActionButton(
                  heroTag: "macroCategoryButton",
                  onPressed:
                      () => MacroCategoryModal.show(
                        context,
                        type: widget.type,
                        onCategoryUpdated: _loadData,
                      ),
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Categorie',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      var category = categories[index];
                      return ListTile(
                        title: Text(category['name']),
                        subtitle: Text(
                          'Macrocategoria: ${category['macro_category']}',
                        ),
                        onTap:
                            () => CategoryModal.show(
                              context,
                              category: category,
                              macroCategories: macroCategories,
                              type: widget.type,
                              onCategoryUpdated: _loadData,
                            ),
                      );
                    },
                  ),
                ),
                FloatingActionButton(
                  heroTag: "categoryButton",
                  onPressed:
                      () => CategoryModal.show(
                        context,
                        type: widget.type,
                        macroCategories: macroCategories,
                        onCategoryUpdated: _loadData,
                      ),
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
