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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLegend(graphData), // Add the legend above the chart
                SizedBox(height: 16), // Spacing between legend and chart
                Center(
                  child: AspectRatio(
                    aspectRatio: 1, // Make the chart square
                    child: LineChart(buildLineChart(graphData)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build a custom legend widget
  Widget buildLegend(Map<String, List<Map<String, dynamic>>> graphData) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: graphData.keys.map((meterName) {
        final color =
            meterColorsMap[graphData[meterName]!.first['color']] ?? Colors.grey;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4),
            Text(
              meterName,
              style: TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  LineChartData buildLineChart(
      Map<String, List<Map<String, dynamic>>> graphData) {
    List<LineChartBarData> lines = [];

    graphData.forEach((meterName, data) {
      final color = meterColorsMap[data.first['color']] ?? Colors.grey;

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
        dotData: FlDotData(show: true),
      ));
    });

    // Calculate X and Y-axis ranges
    double maxValue = graphData.values
        .expand((data) => data)
        .map((e) => (e['cost'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    double roundedMax = getRoundedMax(maxValue, 40);

    double maxX = graphData.values.first.length - 0.5;

    return LineChartData(
      minY: 0,
      maxY: roundedMax,
      maxX: maxX,
      lineBarsData: lines,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                '\$${value.toInt()}',
                style: TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              int totalMonths = graphData.values.first.length;
              int tickInterval = (totalMonths / 6).ceil();

              if (value.toInt() % tickInterval == 0 &&
                  value.toInt() >= 0 &&
                  value.toInt() < totalMonths) {
                final rawMonth = graphData.values.first[value.toInt()]['month'];
                try {
                  final date = DateTime.parse('$rawMonth-01');
                  final formattedMonth =
                      '${_getMonthName(date.month)}\n${date.year}';
                  return Text(
                    formattedMonth,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10),
                  );
                } catch (e) {
                  return Text(
                    'Invalid Date',
                    style: TextStyle(fontSize: 8, color: Colors.red),
                  );
                }
              }
              return Text('');
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value == meta.max) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Cost',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: true),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              final monthIndex = touchedSpot.x.toInt();
              final meterName = graphData.keys.elementAt(touchedSpot.barIndex);
              final meterData = graphData[meterName]?[monthIndex];
              final rawMonth = meterData?['month'];

              String tooltipText = '';

              // Retrieve the month and year
              if (rawMonth != null) {
                try {
                  final date = DateTime.parse('$rawMonth-01');
                  tooltipText += '${_getMonthName(date.month)} ${date.year}\n';
                } catch (e) {
                  tooltipText += 'Invalid Date\n';
                }
              }

              // Add meter-specific cost
              final cost = (meterData?['cost'] ?? 0).toStringAsFixed(2);
              tooltipText += '$meterName:  \$$cost';

              return LineTooltipItem(
                tooltipText.trim(),
                TextStyle(color: Colors.black, fontSize: 12),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  /// Utility function to round up to the nearest interval
  double getRoundedMax(double maxValue, double interval) {
    return ((maxValue / interval).ceil() * interval).toDouble();
  }

  /// Helper function to get abbreviated month name
  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return month > 0 && month <= 12 ? monthNames[month - 1] : 'Unknown';
  }
}
