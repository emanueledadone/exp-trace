import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/charts_controller.dart';
import '../modal/widget/base_text.dart';

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
      body: Column(children: [_buildFilters(), Expanded(child: _buildChart())]),
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
            Wrap(
              spacing: 8,
              children: [
                SegmentedButton<String>(
                  selected: {_controller.selectedFilter},
                  onSelectionChanged:
                      (selection) => _controller.updateFilter(selection.first),
                  segments: const [
                    ButtonSegment(
                      value: 'Entrate vs Uscite',
                      label: Text('Entrate vs Uscite'),
                    ),
                    ButtonSegment(
                      value: 'Solo Entrate',
                      label: Text('Solo Entrate'),
                    ),
                    ButtonSegment(
                      value: 'Solo Uscite',
                      label: Text('Solo Uscite'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                BaseTextField(
                  controller: _controller.dateController,
                  label: "Data",
                  readOnly: true,
                  suffixIcon: Icons.calendar_today,
                  onTap: () => _controller.pickDate(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final data = <LineChartBarData>[
      if (_controller.selectedFilter != 'Solo Uscite')
        LineChartBarData(
          spots: _controller.getConstantEntrateData(),
          isCurved: false,
          color: Colors.green,
          barWidth: 4,
        ),
      if (_controller.selectedFilter != 'Solo Entrate')
        LineChartBarData(
          spots: _controller.getCumulativeUsciteData(),
          isCurved: true,
          curveSmoothness: 0.2,
          color: Colors.red,
          barWidth: 4,
        ),
    ];

    return Column(
      children: [
        const Text("Grafico a linea - Ripartizione entrate vs uscite"),
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: _controller.maxAmount,
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text('Giorni'),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (value, _) {
                        final d = _controller.getDateFromValue(value);
                        return Text('${d.day}/${d.month}');
                      },
                    ),
                  ),
                ),
                lineBarsData: data,
              ),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
