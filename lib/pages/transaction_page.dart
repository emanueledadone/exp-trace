import 'package:exp_trace/modal/transaction_modal.dart';
import 'package:exp_trace/repositories/transaction_repository.dart';
import 'package:exp_trace/utils/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class TransactionPage extends StatefulWidget {
  final TransactionType type; // 'entrata' o 'uscita'

  const TransactionPage({super.key, required this.type});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
  double totalAmount = 0.0;
  DateTime selectedDate = DateTime.now();

  Future<void> _loadTransactions() async {
    String month = selectedDate.month.toString();
    List<Map<String, dynamic>> transactions = await TransactionRepository()
        .fetchFilteredTransactions(type: widget.type, month: month);

    // Raggruppare le transazioni per data
    groupedTransactions = {};
    totalAmount = 0.0;

    for (var transaction in transactions) {
      String date = DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime.parse(transaction['date']));
      totalAmount += transaction['amount'] as double;

      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]?.add(transaction);
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _changePeriod(bool forward) {
    setState(() {
      selectedDate = DateTime(
        selectedDate.year,
        selectedDate.month + (forward ? 1 : -1),
        1,
      );
    });
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == TransactionType.entrata ? "Entrate" : "Uscite",
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Totale: ${totalAmount.toStringAsFixed(2)} €",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left),
                onPressed: () => _changePeriod(false),
              ),
              Text(DateFormat('MM/yyyy').format(selectedDate)),
              IconButton(
                icon: Icon(Icons.arrow_right),
                onPressed: () => _changePeriod(true),
              ),
            ],
          ),
          Expanded(
            child:
                groupedTransactions.isEmpty
                    ? Center(child: Text('Nessun movimento'))
                    : ListView.builder(
                      itemCount: groupedTransactions.keys.length,
                      itemBuilder: (context, index) {
                        String date = groupedTransactions.keys.elementAt(index);
                        List<Map<String, dynamic>> transactionsForDate =
                            groupedTransactions[date]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                date,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...transactionsForDate.map((transaction) {
                              IconData? icon =
                                  transaction['icon'] != null
                                      ? AppIcons
                                          .iconMapping[transaction['icon']]
                                      : null;
                              int? intColor =
                                  transaction['backgroundColor'] != null
                                      ? int.tryParse(
                                        transaction['backgroundColor'],
                                        radix: 16,
                                      )
                                      : null;
                              Color color =
                                  intColor != null
                                      ? Color(intColor)
                                      : Colors.transparent;

                              Widget subtitle = Text(
                                "${transaction['amount']} € - ${transaction['notes']}",
                              );
                              if (icon != null) {
                                subtitle = Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          icon,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "${transaction['amount']} € - ${transaction['notes']}",
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return ListTile(
                                title: Text(transaction['category']),
                                subtitle: subtitle,
                                onTap:
                                    () => TransactionModal.show(
                                      context,
                                      type: widget.type,
                                      transaction: transaction,
                                      onTransactionUpdated: _loadTransactions,
                                    ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => TransactionModal.show(
              context,
              type: widget.type,
              onTransactionUpdated: _loadTransactions,
            ),
        child: Icon(Icons.add),
      ),
    );
  }
}
