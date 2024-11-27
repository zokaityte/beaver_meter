import 'package:beaver_meter/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../constants/config.dart';

class TrendsPage extends StatefulWidget {
  @override
  _TrendsPageState createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> {
  int selectedYear = DateTime.now().year;

  late Future<Map<String, List<Map<String, dynamic>>>> graphDataFuture;

  @override
  void initState() {
    super.initState();
    graphDataFuture = prepareGraphData();
  }

  Future<Map<String, List<Map<String, dynamic>>>> prepareGraphData() async {
    final data =
        await DatabaseHelper().getMonthlyUsageAndCost(selectedYear.toString());

    // Initialize graphData with placeholders for all months
    Map<String, List<Map<String, dynamic>>> graphData = {};

    // Create a list of all months (Jan-Dec)
    final allMonths = List.generate(12, (index) {
      final month = index + 1; // 1-based month
      return '${selectedYear}-${month.toString().padLeft(2, '0')}'; // e.g., 2024-01
    });

    // Populate all months with null costs initially
    for (var row in data) {
      final meterName = row['meter_name'];
      final meterColor = row['meter_color'];

      if (!graphData.containsKey(meterName)) {
        graphData[meterName] = allMonths.map((month) {
          return {
            'month': month,
            'cost': null, // Set cost to null for missing data
            'color': meterColor,
          };
        }).toList();
      }
    }

    // Override placeholders with actual data
    for (var row in data) {
      final meterName = row['meter_name'];
      final month = row['month'];
      final cost = row['total_cost'];

      final monthIndex = allMonths.indexOf(month);
      if (monthIndex != -1) {
        graphData[meterName]![monthIndex]['cost'] = cost;
      }
    }

    return graphData;
  }

  void changeYear(int year) {
    setState(() {
      selectedYear = year;
      graphDataFuture = prepareGraphData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cost Trends - $selectedYear'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              changeYear(selectedYear - 1); // Go to the previous year
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              changeYear(selectedYear + 1); // Go to the next year
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: graphDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available for $selectedYear'));
          }

          final graphData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLegend(graphData),
                SizedBox(height: 16),
                Center(
                  child: AspectRatio(
                    aspectRatio: 1,
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

      // Create spots only for months with non-null costs
      List<FlSpot> spots = data
          .asMap()
          .entries
          .where((entry) =>
              entry.value['cost'] != null) // Skip months with null cost
          .map((entry) {
        final monthIndex = entry.key.toDouble(); // Index from 0 to 11 (Jan-Dec)
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

    // Set the X-axis range to cover Jan (0) to Dec (11)
    return LineChartData(
      minY: 0,
      maxX: 11, // Ensure X-axis covers all 12 months (Jan = 0, Dec = 11)
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
              // Map X-axis value (0-11) to month names
              const months = [
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
              if (value.toInt() >= 0 && value.toInt() < 12) {
                return Text(
                  months[value.toInt()],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                );
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
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ));
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
            if (touchedSpots.isEmpty) return [];

            final monthIndex = touchedSpots.first.x.toInt();
            final monthData = <String, String>{};

            // Collect data for all meters at the same x-value
            for (var touchedSpot in touchedSpots) {
              final meterName = graphData.keys.elementAt(touchedSpot.barIndex);
              final meterData = graphData[meterName]?[monthIndex];
              final cost = (meterData?['cost'] ?? 0).toStringAsFixed(2);
              monthData[meterName] = '\$$cost';
            }

            // Construct consolidated tooltip
            String tooltipText = '';
            if (monthData.isNotEmpty) {
              const months = [
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
              final monthName = months[monthIndex];
              tooltipText += '$monthName ${selectedYear}\n';
              monthData.forEach((meterName, cost) {
                tooltipText += '$meterName: $cost\n';
              });
            }

            // Create tooltip only for the first touchedSpot
            return touchedSpots.asMap().entries.map((entry) {
              if (entry.key == 0) {
                return LineTooltipItem(
                  tooltipText.trim(),
                  TextStyle(color: Colors.black, fontSize: 12),
                );
              } else {
                return null;
              }
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
