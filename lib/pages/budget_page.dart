import 'package:exp_trace/database/database_helper.dart';
import 'package:exp_trace/repositories/budget_repository.dart';
import 'package:exp_trace/repositories/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../modal/budget_modal.dart';
import '../repositories/transaction_repository.dart';
import '../widgets/budget_list.dart';
import '../widgets/custom_progress_bar.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final BudgetRepository budgetRepository = BudgetRepository();
  final TransactionRepository transactionRepository = TransactionRepository();
  final CategoryRepository categoryRepository = CategoryRepository();
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> budgetData = [];
  bool isMonthly = true;
  String period = 'mensile';
  double totalExpense = 0.0;
  double budgetUsage = 0.0;
  double budgetValue = 0.0;
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadBudget();
  }

  Future<void> _loadCategories() async {
    categories = await CategoryRepository().fetchCategoriesWithoutBudget(
      period,
    );
  }

  Future<void> _loadBudget() async {
    String month = selectedDate.month.toString();
    String year = selectedDate.year.toString();

    List<Map<String, dynamic>> macroBudget =
        isMonthly
            ? await budgetRepository.fetchMonthlyBudget(month, year)
            : await budgetRepository.fetchAnnualBudget(year);

    List<Map<String, dynamic>> categoryDetails = await budgetRepository
        .fetchCategoryDetails(period, isMonthly ? month : null, year);

    List<Map<String, dynamic>> transactions = await transactionRepository
        .fetchFilteredTransactions(
          month: isMonthly ? month : null,
          year: year,
          type: TransactionType.uscita,
        );

    // Calcola le spese per ogni macrocategoria
    Map<int, double> spentPerMacroCategory = {};
    for (var transaction in transactions) {
      int macroCategoryId = transaction['macro_category_id'];
      double amount = transaction['amount']?.toDouble() ?? 0.0;

      if (spentPerMacroCategory.containsKey(macroCategoryId)) {
        spentPerMacroCategory[macroCategoryId] =
            spentPerMacroCategory[macroCategoryId]! + amount;
      } else {
        spentPerMacroCategory[macroCategoryId] = amount;
      }
    }

    setState(() {
      budgetData =
          macroBudget.map((macro) {
            List<Map<String, dynamic>> categories =
                categoryDetails
                    .where(
                      (category) =>
                          category['macro_category_id'] == macro['id'],
                    )
                    .toList();

            return {
              ...macro,
              'categories': categories,
              'spent': spentPerMacroCategory[macro['id']] ?? 0.0,
            };
          }).toList();

      // Calcolo le spese totali
      totalExpense = 0.0;
      for (var macro in spentPerMacroCategory.values) {
        totalExpense = macro + totalExpense;
      }

      budgetValue = macroBudget.fold(
        0.0,
        (sum, item) =>
            sum + (item['budget'] is num ? item['budget'].toDouble() : 0.0),
      );
      if (budgetValue == 0.0) {
        budgetUsage = 0;
      } else {
        budgetUsage = (totalExpense / budgetValue);
      }
    });
  }

  void _changePeriod(bool forward) {
    setState(() {
      selectedDate =
          isMonthly
              ? DateTime(
                selectedDate.year,
                selectedDate.month + (forward ? 1 : -1),
                1,
              )
              : DateTime(selectedDate.year + (forward ? 1 : -1));
    });
    _loadBudget();
  }

  void _togglePeriod() {
    setState(() {
      isMonthly = !isMonthly;
      period = isMonthly ? 'mensile' : 'annuale';
    });
    _loadBudget();
  }

  @override
  Widget build(BuildContext context) {
    final String budget =
        budgetValue == 0
            ? ""
            : "${totalExpense.toStringAsFixed(1)}/${budgetValue.toStringAsFixed(1)} €";
    return Scaffold(
      appBar: AppBar(
        title: Text("Bilancio $period"),
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0), // Margine a destra
            child: FloatingActionButton(
              onPressed:
                  () => BudgetModal.show(
                    context,
                    period: period,
                    onBudgetUpdated: _loadBudget,
                    categories: categories,
                  ),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          CustomProgressBar(
            title: 'Bilancio',
            dimensione: Size.titolo,
            percent: budgetUsage,
            subTitle: budget,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left),
                onPressed: () => _changePeriod(false),
              ),
              Text(
                DateFormat(isMonthly ? 'MM/yyyy' : 'yyyy').format(selectedDate),
              ),
              IconButton(
                icon: Icon(Icons.arrow_right),
                onPressed: () => _changePeriod(true),
              ),
            ],
          ),
          Expanded(
            child: BudgetListWidget(
              budgetData: budgetData,
              onShowModal:
                  (context, item) => BudgetModal.show(
                    context,
                    budget: item,
                    period: period,
                    categories: categories,
                    onBudgetUpdated: _loadBudget,
                  ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Mensile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Annuale",
          ),
        ],
        currentIndex: isMonthly ? 0 : 1,
        onTap: (_) => _togglePeriod(),
      ),
    );
  }
}
