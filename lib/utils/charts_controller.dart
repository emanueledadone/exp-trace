import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';
import '../repositories/transaction_repository.dart';
import '../utils/utils.dart';

class ChartsController extends ChangeNotifier {
  final dateController = TextEditingController();
  List<Map<String, dynamic>> income = [], expense = [];
  double maxAmount = 1500.0, totalEntrate = 0.0;
  String selectedFilter = 'Entrate vs Uscite';
  DateTime selectedDate = DateTime.now();
  int daysOfTheMonth = 30;

  void init() {
    dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final repo = TransactionRepository();
    final year = selectedDate.year.toString();
    final month = selectedDate.month.toString().padLeft(2, '0');

    income =
        selectedFilter != 'Solo Uscite'
            ? await repo.fetchFilteredTransactions(
              type: TransactionType.entrata,
              year: year,
              month: month,
            )
            : [];

    expense =
        selectedFilter != 'Solo Entrate'
            ? await repo.fetchFilteredTransactions(
              type: TransactionType.uscita,
              year: year,
              month: month,
            )
            : [];

    daysOfTheMonth = getDaysInMonth(selectedDate);
    totalEntrate = income.fold(0.0, (sum, t) => sum + (t['amount'] ?? 0.0));
    maxAmount = totalEntrate + (10 - totalEntrate % 10) + 10;
    notifyListeners();
  }

  void updateFilter(String filter) {
    selectedFilter = filter;
    _loadTransactions();
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedDate = picked;
      dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      _loadTransactions();
    }
  }

  DateTime getDateFromValue(double value) =>
      selectedDate.add(Duration(days: value.toInt()));

  List<FlSpot> getConstantEntrateData() {
    final avg = totalEntrate / daysOfTheMonth;
    return List.generate(daysOfTheMonth, (i) => FlSpot(i.toDouble(), avg));
  }

  List<FlSpot> getCumulativeUsciteData() {
    double sum = 0;
    return List.generate(daysOfTheMonth, (i) {
      sum += getUscitaPerGiorno(i);
      return FlSpot(i.toDouble(), sum);
    });
  }

  double getUscitaPerGiorno(int dayIndex) {
    final date = DateTime(selectedDate.year, selectedDate.month, dayIndex + 1);
    return expense
        .where((t) => DateTime.parse(t['date']).day == date.day)
        .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0.0));
  }
}
