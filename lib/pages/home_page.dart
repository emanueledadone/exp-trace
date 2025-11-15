import 'package:exp_trace/pages/charts_page.dart';
import 'package:exp_trace/pages/settings_page.dart';
import 'package:exp_trace/pages/transaction_page.dart';
import 'package:exp_trace/repositories/budget_repository.dart';
import 'package:exp_trace/widgets/custom_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../main.dart';

import '../repositories/transaction_repository.dart';
import '../widgets/custom_button.dart';
import 'accounts_page.dart';
import 'budget_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TransactionRepository transactionRepository = TransactionRepository();
  final BudgetRepository budgetRepository = BudgetRepository();
  final String month = DateTime.now().month.toString();
  final String year = DateTime.now().year.toString();
  List<Map<String, dynamic>> income = [];
  List<Map<String, dynamic>> expense = [];
  double macroBudget = 0.0;
  double percent = 0.0;
  double spent = 0.0;
  double earn = 0.0;
  late String entrate = '';
  late String uscite = '';
  late String budget = '';
  late String conto = '';
  bool showValues = true;
  /* late Timer _timer;
  int _stepsToday = 0;
  int _latestRawSteps = 0;
  StreamSubscription<StepCount>? _stepSubscription;

  Future<void> requestPermissions() async {
    if (await Permission.activityRecognition.request().isGranted) {
      print('Permesso concesso');
    } else {
      print('Permesso negato');
    }
  }
*/
  @override
  void initState() {
    super.initState();
    _loadData();
    _loadPreference();
    /*requestPermissions().then((_) {
      _startListening();
      _startTimer();
    });*/
  }

  void _loadPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showValues = prefs.getBool('showValues') ?? true;
    });
  }

  void _toggleVisibility() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showValues = !showValues;
      prefs.setBool('showValues', showValues);
    });
  }

  void _loadData() async {
    income = await transactionRepository.fetchFilteredTransactions(
      type: TransactionType.entrata,
      month: month,
      year: year,
    );
    expense = await transactionRepository.fetchFilteredTransactions(
      type: TransactionType.uscita,
      month: month,
      year: year,
    );

    macroBudget = await budgetRepository.getBudget();

    setState(() {
      earn = income.fold(
        0.0,
        (sum, item) =>
            sum + (item['amount'] is num ? item['amount'].toDouble() : 0.0),
      );

      spent = expense.fold(
        0.0,
        (sum, item) =>
            sum + (item['amount'] is num ? item['amount'].toDouble() : 0.0),
      );

      entrate = '${earn.toStringAsFixed(0)}€';
      uscite = '${spent.toStringAsFixed(0)}€';

      //conto = '${(earn - spent).toStringAsFixed(0)}€';

      if (macroBudget > 0) {
        percent = spent / macroBudget;
        budget =
            '${(percent * 100).toStringAsFixed(0)}% [${spent.toStringAsFixed(0)} / ${macroBudget.toStringAsFixed(0)}] €';
      } else {
        budget = '0%';
      }
    });
  }
  /*
  @override
  void dispose() {
    _stepSubscription?.cancel();
    _timer.cancel();
    super.dispose();
  }

  void _startListening() {
    _stepSubscription = Pedometer.stepCountStream.listen((StepCount event) {
      // Salva il valore dei passi attuale, aggiornato in tempo reale ma senza chiamare setState
      _latestRawSteps = event.steps;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
      _handleStepUpdate();
    });
  }

  Future<void> _handleStepUpdate() async {
    try {
      int updatedSteps = await StepRepository().insertOrUpdateSteps(
        DateTime.now(),
        _latestRawSteps,
      );

      if (mounted) {
        setState(() {
          _stepsToday = updatedSteps;
        });
      }
    } catch (e) {
      print('Errore durante l\'aggiornamento dei passi: $e');
    }
  }

  void _stopListening() {
    _stepSubscription?.cancel();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(showValues ? Icons.visibility : Icons.visibility_off),
            onPressed: _toggleVisibility,
          ),
          _iconButton(context, Icons.settings, Colors.black, SettingsPage()),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                // "Conti" alto due righe
                Expanded(
                  child: SizedBox(
                    height: 124,
                    child: CustomButton(
                      text: 'Conto ${showValues ? conto : '****'}',
                      icon: Icons.account_balance,
                      color: Colors.blue,
                      onPressed:
                          () => navigateTo(context, AccountsPage()).then((_) {
                            _loadData();
                          }),
                    ),
                  ),
                ),
                SizedBox(width: 4),
                // "Entrate" e "Uscite" a destra di "Conti"
                Column(
                  mainAxisSize:
                      MainAxisSize.min, // Evita problemi di altezza infinita
                  children: [
                    CustomButton(
                      isWide: true,

                      text: 'Entrate ${showValues ? entrate : '****'}',
                      icon: Icons.input,
                      color: Colors.green,
                      onPressed:
                          () => navigateTo(
                            context,
                            TransactionPage(type: TransactionType.entrata),
                          ).then((_) {
                            _loadData();
                          }),
                    ),
                    SizedBox(height: 4),
                    CustomButton(
                      isWide: true,
                      text: 'Uscite ${showValues ? uscite : '****'}',
                      icon: Icons.output,
                      color: Colors.red,
                      onPressed:
                          () => navigateTo(
                            context,
                            TransactionPage(type: TransactionType.uscita),
                          ).then((_) {
                            _loadData();
                          }),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 4),
            // "Bilancio" largo su due colonne
            SizedBox(
              height: 120, // Altezza maggiore
              width: double.infinity,
              child: CustomButton(
                body: CustomProgressBar(
                  title: 'Bilancio',
                  percent: percent,
                  subTitle:
                      showValues
                          ? budget
                          : '${(percent * 100).toStringAsFixed(0)}% ****',
                  dimensione: Size.sottoTitolo,
                  fontColor: Colors.white,
                  progressColor: Colors.green,
                ),
                icon: Icons.assessment,
                color: Colors.orange,
                onPressed:
                    () => navigateTo(context, BudgetPage()).then((_) {
                      _loadData();
                    }),
              ),
            ),
            SizedBox(height: 4),
            SizedBox(
              height: 120, // Altezza maggiore
              width: double.infinity,
              // "Grafici" da solo sulla quarta riga
              child: CustomButton(
                text: 'Grafici',
                icon: Icons.pie_chart,
                color: Colors.purple,
                onPressed:
                    () => navigateTo(context, ChartsPage()).then((_) {
                      _loadData();
                    }),
              ),
            ),
            /*Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: _buildStepCounter(),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  /*
  Widget _buildStepCounter() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(Icons.directions_walk, size: 48, color: Colors.blue),
          SizedBox(height: 8),
          Text(
            'Passi di oggi: $_stepsToday',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }*/

  // Icona impostazioni
  Widget _iconButton(
    BuildContext context,
    IconData icon,
    Color color,
    Widget page,
  ) {
    return IconButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Angoli meno arrotondati
        ),
      ),
      icon: Icon(icon, color: color),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        ).then((_) {
          _loadData();
        });
      },
      color: Colors.grey,
    );
  }
}
