import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/charts_controller.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  final _controller = ChartsController();

  @override
  void initState() {
    super.initState();
    _controller.init();
    _controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Andamento')),
      body: Column(
        children: [_buildFilters(), Expanded(child: _buildCharts())],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Text(
              "Filtri",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Row(
              children: [
                // --- Tipo movimento ---
                DropdownButton<String>(
                  value: _controller.selectedType,
                  items: const [
                    DropdownMenuItem(
                      value: "all",
                      child: Text("Entrate & Uscite"),
                    ),
                    DropdownMenuItem(
                      value: "entrate",
                      child: Text("Solo Entrate"),
                    ),
                    DropdownMenuItem(
                      value: "uscite",
                      child: Text("Solo Uscite"),
                    ),
                  ],
                  onChanged: (val) => _controller.updateType(val!),
                ),
                Row(
                  children: [
                    const SizedBox(height: 16),

                    // --- Periodo ---
                    DropdownButton<String>(
                      value: _controller.selectedPeriod,
                      items: const [
                        DropdownMenuItem(
                          value: "monthYear",
                          child: Text("Per mese/anno"),
                        ),
                        DropdownMenuItem(
                          value: "year",
                          child: Text("Tutto l'anno"),
                        ),
                      ],
                      onChanged: (val) => _controller.updatePeriod(val!),
                    ),

                    const SizedBox(height: 16),

                    if (_controller.selectedPeriod == "monthYear")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButton<int>(
                            value: _controller.selectedDate.month,
                            items: List.generate(
                              12,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text(_controller.monthName(i + 1)),
                              ),
                            ),
                            onChanged: (m) => _controller.updateMonth(m!),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<int>(
                            value: _controller.selectedDate.year,
                            items: List.generate(
                              10,
                              (i) => DropdownMenuItem(
                                value: DateTime.now().year - i,
                                child: Text('${DateTime.now().year - i}'),
                              ),
                            ),
                            onChanged: (y) => _controller.updateYear(y!),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_controller.selectedType == "all") ...[
            const Text("Grafico a barre - Entrate vs Uscite"),
            SizedBox(height: 250, child: _buildBarChart()),
          ] else ...[
            Text("Grafico a linea - ${_controller.selectedType}"),
            SizedBox(height: 250, child: _buildLineChart()),
          ],
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BarChart(
        BarChartData(
          maxY: 3000,
          titlesData: FlTitlesData(
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ), // disattiva scritte sopra
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, // lascia 1, così hai controllo totale
                getTitlesWidget: (value, _) {
                  final v = value.toInt();

                  if (_controller.selectedPeriod == "year") {
                    // Mostra solo mesi pari
                    if (v % 2 == 0) {
                      return Text(_controller.monthName(v));
                    }
                    return const SizedBox.shrink();
                  } else {
                    // Mostra solo alcuni giorni (1, 10, 20, 30)
                    if (v == 1 || v % 5 == 0) {
                      final d = _controller.getDateFromValue(value);
                      return Text('${d.day}/${d.month}');
                    }
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
          barGroups: _controller.getBarData(),
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    final data = _controller.getLineData();
    final trend = _controller.getTrendLine(data);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY:
              _controller.selectedType == "uscite"
                  ? (_controller.selectedPeriod == "year" ? 2000 : 1000)
                  : 3000,
          titlesData: FlTitlesData(
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ), // disattiva scritte sopra
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, // lascia 1, così hai controllo totale
                getTitlesWidget: (value, _) {
                  final v = value.toInt();

                  if (_controller.selectedPeriod == "year") {
                    // Mostra solo mesi pari
                    if (v % 2 == 0) {
                      return Text(_controller.monthName(v));
                    }
                    return const SizedBox.shrink();
                  } else {
                    // Mostra solo alcuni giorni (1, 10, 20, 30)
                    if (v == 1 || v % 5 == 0) {
                      final d = _controller.getDateFromValue(value);
                      return Text('${d.day}/${d.month}');
                    }
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: data,
              isCurved: false,
              color:
                  _controller.selectedType == "entrate"
                      ? Colors.green
                      : Colors.red,
              barWidth: 3,
            ),
            LineChartBarData(
              spots: trend,
              isCurved: false,
              color: Colors.blue,
              dashArray: [5, 5],
              barWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
