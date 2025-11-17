import 'package:exp_trace/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../repositories/transaction_repository.dart';
import '../utils/utils.dart';

class ChartsController extends ChangeNotifier {
  List<Map<String, dynamic>> income = [], expense = [];
  String selectedType = 'all'; // all, entrate, uscite
  String selectedPeriod = 'monthYear'; // monthYear, year
  DateTime selectedDate = DateTime.now();

  void init() => _loadTransactions();

  Future<void> _loadTransactions() async {
    final repo = TransactionRepository();
    final year = selectedDate.year.toString();
    final month =
        selectedPeriod == 'monthYear'
            ? selectedDate.month.toString().padLeft(2, '0')
            : null;

    income =
        selectedType != 'uscite'
            ? await repo.fetchFilteredTransactions(
              type: TransactionType.entrata,
              year: year,
              month: month,
            )
            : [];

    expense =
        selectedType != 'entrate'
            ? await repo.fetchFilteredTransactions(
              type: TransactionType.uscita,
              year: year,
              month: month,
            )
            : [];

    notifyListeners();
  }

  /// Restituisce la data corrispondente al valore X del grafico
  DateTime getDateFromValue(double value) {
    if (selectedPeriod == 'year') {
      // Se filtro per anno → interpreto value come mese
      return DateTime(selectedDate.year, value.toInt(), 1);
    } else {
      // Se filtro per mese → interpreto value come giorno
      return DateTime(selectedDate.year, selectedDate.month, value.toInt());
    }
  }

  void updateType(String type) {
    selectedType = type;
    _loadTransactions();
  }

  void updatePeriod(String period) {
    selectedPeriod = period;
    _loadTransactions();
  }

  void updateMonth(int month) {
    selectedDate = DateTime(selectedDate.year, month, 1);
    _loadTransactions();
  }

  void updateYear(int year) {
    selectedDate = DateTime(year, selectedDate.month, 1);
    _loadTransactions();
  }

  String monthName(int month) =>
      DateFormat.MMMM('it_IT').format(DateTime(0, month));

  // --- Serie per grafici ---
  List<BarChartGroupData> getBarData() {
    if (selectedPeriod == 'year') {
      // Raggruppo per mese
      return List.generate(12, (i) {
        final month = i + 1;
        final entrate = income
            .where((t) => DateTime.parse(t['date']).month == month)
            .fold(0.0, (s, t) => s + (t['amount'] ?? 0.0));
        final uscite = expense
            .where((t) => DateTime.parse(t['date']).month == month)
            .fold(0.0, (s, t) => s + (t['amount'] ?? 0.0));
        return BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(toY: entrate, color: Colors.green),
            BarChartRodData(toY: uscite, color: Colors.red),
          ],
        );
      });
    } else {
      // Raggruppo per giorno
      final days = getDaysInMonth(selectedDate);
      return List.generate(days, (i) {
        final day = i + 1;
        final entrate = income
            .where((t) => DateTime.parse(t['date']).day == day)
            .fold(0.0, (s, t) => s + (t['amount'] ?? 0.0));
        final uscite = expense
            .where((t) => DateTime.parse(t['date']).day == day)
            .fold(0.0, (s, t) => s + (t['amount'] ?? 0.0));
        return BarChartGroupData(
          x: day,
          barRods: [
            BarChartRodData(toY: entrate, color: Colors.green),
            BarChartRodData(toY: uscite, color: Colors.red),
          ],
        );
      });
    }
  }

  List<FlSpot> getLineData() {
    if (selectedPeriod == 'year') {
      // Raggruppo per mese
      return List.generate(12, (i) {
        final month = i + 1;
        final serie = selectedType == 'entrate' ? income : expense;
        final totale = serie
            .where((t) => DateTime.parse(t['date']).month == month)
            .fold(0.0, (s, t) => s + (t['amount'] ?? 0.0));
        return FlSpot(month.toDouble(), totale);
      });
    } else {
      // Raggruppo per giorno
      final days = getDaysInMonth(selectedDate);
      return List.generate(days, (i) {
        final day = i + 1;
        final serie = selectedType == 'entrate' ? income : expense;
        final totale = serie
            .where((t) => DateTime.parse(t['date']).day == day)
            .fold(0.0, (s, t) => s + (t['amount'] ?? 0.0));
        return FlSpot(day.toDouble(), totale);
      });
    }
  }

  // --- Linea di tendenza (regressione lineare semplice) ---
  List<FlSpot> getTrendLine(List<FlSpot> data) {
    // Considero solo i punti con dati reali
    final filtered = data.where((e) => e.y > 0).toList();
    if (filtered.length < 2) {
      // Se ho 0 o 1 punto → niente linea di tendenza
      return [];
    }

    final n = filtered.length;
    final meanX = filtered.map((e) => e.x).reduce((a, b) => a + b) / n;
    final meanY = filtered.map((e) => e.y).reduce((a, b) => a + b) / n;

    final num = filtered
        .map((e) => (e.x - meanX) * (e.y - meanY))
        .reduce((a, b) => a + b);
    final den = filtered
        .map((e) => (e.x - meanX) * (e.x - meanX))
        .reduce((a, b) => a + b);

    if (den == 0) return []; // evita divisione per zero

    final slope = num / den;
    final intercept = meanY - slope * meanX;

    return [
      FlSpot(filtered.first.x, slope * filtered.first.x + intercept),
      FlSpot(filtered.last.x, slope * filtered.last.x + intercept),
    ];
  }
}
