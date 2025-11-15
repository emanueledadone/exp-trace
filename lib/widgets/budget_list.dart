import 'package:exp_trace/widgets/custom_progress_bar.dart';
import 'package:flutter/material.dart';
import '../utils/app_icons.dart'; // Importa la mappa di icone

class BudgetListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> budgetData;
  final void Function(BuildContext, Map<String, dynamic>) onShowModal;

  const BudgetListWidget({
    super.key,
    required this.budgetData,
    required this.onShowModal,
  });

  @override
  _BudgetListWidgetState createState() => _BudgetListWidgetState();
}

class _BudgetListWidgetState extends State<BudgetListWidget> {
  Map<int, bool> expandedItems = {};

  @override
  Widget build(BuildContext context) {
    return widget.budgetData.isEmpty
        ? const Center(child: Text("Nessun budget inserito"))
        : ListView.builder(
          itemCount: widget.budgetData.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> item = widget.budgetData[index];
            double spent = item['spent']?.toDouble() ?? 0.0;
            double budget = item['budget']?.toDouble() ?? 0.0;
            double percent = budget > 0 ? spent / budget : 0.0;
            bool expanded = expandedItems[index] ?? false;

            IconData? icon = AppIcons.iconMapping[item['icon']];
            int? intColor =
                item['backgroundColor'] != null
                    ? int.tryParse(item['backgroundColor'], radix: 16)
                    : null;
            Color color =
                intColor != null ? Color(intColor) : Colors.transparent;

            return InkWell(
              onTap: () {
                setState(() {
                  expandedItems[index] = !expanded;
                });
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      if (icon != null)
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color, // Usa il colore salvato
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, color: Colors.white, size: 40),
                          ),
                        ),
                      Expanded(
                        child: CustomProgressBar(
                          title: item['name'],
                          dimensione: Size.titolo,
                          percent: percent,
                          subTitle:
                              '${spent.toStringAsFixed(1)}/${budget.toStringAsFixed(1)} €',
                        ),
                      ),
                    ],
                  ),
                  if (expanded) ..._buildCategoryDetails(item),
                ],
              ),
            );
          },
        );
  }

  List<Widget> _buildCategoryDetails(Map<String, dynamic> macroCategory) {
    List<Map<String, dynamic>> categories = macroCategory['categories'] ?? [];

    return categories.map((category) {
      double min = category['spent'].toDouble();
      double max = category['budget'].toDouble();
      double percent = max == 0 ? 0 : min / max;

      Map<String, dynamic> budget = {
        'id': category['budget_id'],
        'period': category['period'],
        'budget': category['budget'],
        'category_id': category['id'],
        'category_name': category['name'],
      };

      return max > 0
          ? GestureDetector(
            onTap: () {
              widget.onShowModal(context, budget);
            },
            child: CustomProgressBar(
              title: category['name'] ?? "Categoria sconosciuta",
              dimensione: Size.dettaglio,
              percent: percent,
              subTitle: '${min.toStringAsFixed(1)}/${max.toStringAsFixed(1)}',
            ),
          )
          : CustomProgressBar(
            title: category['name'] ?? "Categoria sconosciuta",
            dimensione: Size.dettaglio,
            percent: percent,
            subTitle: '',
          );
    }).toList();
  }
}
