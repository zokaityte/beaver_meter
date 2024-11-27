import 'package:beaver_meter/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../constants/config.dart';

class TrendsPage extends StatefulWidget {
  @override
  _TrendsPageState createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> {
  late Future<Map<String, List<Map<String, dynamic>>>> graphDataFuture;

  @override
  void initState() {
    super.initState();
    graphDataFuture = prepareGraphData();
  }

  Future<Map<String, List<Map<String, dynamic>>>> prepareGraphData() async {
    final data = await DatabaseHelper().getMonthlyUsageAndCost();
    Map<String, List<Map<String, dynamic>>> graphData = {};

    for (var row in data) {
      final meterName = row['meter_name'];
      final meterColor =
          row['meter_color']; // Assuming color is part of your query
      final month = row['month'];
      final cost = row['total_cost'] ?? 0.0;

      if (!graphData.containsKey(meterName)) {
        graphData[meterName] = [];
      }
      graphData[meterName]
          ?.add({'month': month, 'cost': cost, 'color': meterColor});
    }

    return graphData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cost Trends')),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: graphDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }

          final graphData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(buildLineChart(graphData)),
          );
        },
      ),
    );
  }

  LineChartData buildLineChart(
      Map<String, List<Map<String, dynamic>>> graphData) {
    List<LineChartBarData> lines = [];
    int index = 0;

    // Build a line for each meter
    graphData.forEach((meterName, data) {
      final color = meterColorsMap[data.first['meter_color']];

      List<FlSpot> spots = data.asMap().entries.map((entry) {
        final monthIndex = entry.key.toDouble();
        final cost = (entry.value['cost'] as num).toDouble();
        return FlSpot(monthIndex, cost);
      }).toList();

      lines.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 4,
        belowBarData: BarAreaData(show: false),
      ));
      index++;
    });

    return LineChartData(
      lineBarsData: lines,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              int intValue = value.toInt();
              if (intValue >= 0 && intValue < graphData.values.first.length) {
                return Text(
                  graphData.values.first[intValue]['month'].toString(),
                  style: const TextStyle(fontSize: 10),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: true),
      gridData: FlGridData(show: true),
    );
  }
}
