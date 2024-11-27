import 'package:beaver_meter/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../constants/config.dart';
import '../providers/settings_provider.dart';

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

    // Populate all months with null costs and usages initially
    for (var row in data) {
      final meterName = row['meter_name'];
      final meterColor = row['meter_color'];
      final meterUnit = row['meter_unit'];

      if (!graphData.containsKey(meterName)) {
        graphData[meterName] = allMonths.map((month) {
          return {
            'month': month,
            'cost': null, // Set cost to null for missing data
            'usage': null, // Set usage to null for missing data
            'color': meterColor,
            'unit': meterUnit,
          };
        }).toList();
      }
    }

    // Override placeholders with actual data
    for (var row in data) {
      final meterName = row['meter_name'];
      final month = row['month'];
      final cost = row['total_cost'];
      final usage = row['monthly_usage'];

      final monthIndex = allMonths.indexOf(month);
      if (monthIndex != -1) {
        graphData[meterName]![monthIndex]['cost'] = cost;
        graphData[meterName]![monthIndex]['usage'] = usage;
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
    final currencySymbol = context.watch<SettingsProvider>().currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                changeYear(selectedYear - 1); // Go to the previous year
              },
            ),
            Text(
              '$selectedYear',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                changeYear(selectedYear + 1); // Go to the next year
              },
            ),
          ],
        ),
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
            child: ListView(
              children: [
                // Original graph
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add title for the graph
                    Text(
                      'Cost',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8), // Spacing between title and legend
                    buildLegend(graphData),
                    SizedBox(height: 16), // Spacing between legend and chart
                    Center(
                      child: AspectRatio(
                        aspectRatio: 1.5,
                        child: LineChart(
                            buildLineChart(graphData, currencySymbol)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height:
                        32), // Spacing between the cost graph and the usage graphs

                // New bar charts for each meter
                ...graphData.entries.map((entry) {
                  final meterName = entry.key;
                  final data = entry.value;
                  final meterColor =
                      meterColorsMap[data.first['color']] ?? Colors.grey;
                  final meterUnit = data.first['unit'] ?? '';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meterName,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Unit: $meterUnit',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: AspectRatio(
                          aspectRatio: 1.5,
                          child: BarChart(
                              buildBarChart(data, meterColor, meterUnit)),
                        ),
                      ),
                      SizedBox(height: 32), // Spacing between graphs
                    ],
                  );
                }).toList(),
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
      Map<String, List<Map<String, dynamic>>> graphData,
      String currencySymbol) {
    final double interval = 40.0;
    final double maxY = getRoundedMax(graphData, interval);

    List<LineChartBarData> lines = [];

    graphData.forEach((meterName, data) {
      final color = meterColorsMap[data.first['color']] ?? Colors.grey;

      // Create spots for all months, including gaps for null or 0 costs
      List<FlSpot?> spots = data.asMap().entries.map((entry) {
        final monthIndex = entry.key.toDouble(); // Index from 0 to 11 (Jan-Dec)
        final cost = entry.value['cost'] != null
            ? (entry.value['cost'] as num).toDouble()
            : null; // Use null for missing values
        return (cost != null && cost != 0) ? FlSpot(monthIndex, cost) : null;
      }).toList();

      // Split spots into segments of consecutive valid (non-null, non-zero) spots
      List<List<FlSpot>> spotSegments = [];
      List<FlSpot> currentSegment = [];

      for (var spot in spots) {
        if (spot != null) {
          currentSegment.add(spot);
        } else {
          if (currentSegment.isNotEmpty) {
            spotSegments.add(currentSegment);
            currentSegment = [];
          }
        }
      }
      if (currentSegment.isNotEmpty) {
        spotSegments.add(currentSegment);
      }

      // Create a LineChartBarData for each segment
      for (var segment in spotSegments) {
        lines.add(LineChartBarData(
          spots: segment,
          isCurved: true,
          color: color,
          barWidth: 4,
          belowBarData: BarAreaData(show: false),
          dotData: FlDotData(show: true), // Show dots for valid points
        ));
      }
    });

    return LineChartData(
      minX: 0,
      maxX: 11, // Ensure X-axis covers all months from Jan to Dec
      minY: 0,
      maxY: maxY, // Use dynamically rounded maxY
      lineBarsData: lines,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 1,
            getTitlesWidget: (value, meta) {
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
              if (value.toInt() >= 0 && value.toInt() < months.length) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    months[value.toInt()],
                    style: TextStyle(fontSize: 10),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: interval, // Ensure grid aligns with Y-axis ticks
            getTitlesWidget: (value, meta) {
              return Text(
                '$currencySymbol ${value.toInt()}',
                style: TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: FlGridData(
        show: true,
        horizontalInterval: interval, // Align grid with Y-axis ticks
      ),
      borderData: FlBorderData(show: false),
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
              monthData[meterName] = '$currencySymbol$cost';
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
                  TextStyle(color: Colors.white, fontSize: 12),
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
  double getRoundedMax(
      Map<String, List<Map<String, dynamic>>> graphData, double interval) {
    double maxY = 0.0;

    graphData.forEach((_, data) {
      for (var entry in data) {
        final cost = entry['cost'];
        if (cost != null && cost > maxY) {
          maxY = cost.toDouble();
        }
      }
    });

    return ((maxY / interval).ceil() * interval)
        .toDouble(); // Round to the nearest interval
  }

  BarChartData buildBarChart(
      List<Map<String, dynamic>> data, Color barColor, String unit) {
    final double interval = _getYInterval(data);
    final double maxY = getRoundedMaxForMeter(data, interval);

    List<BarChartGroupData> barGroups = data.asMap().entries.map((entry) {
      final monthIndex = entry.key;
      final usage = entry.value['usage'] != null
          ? (entry.value['usage'] as num).toDouble()
          : 0.0; // Use 0 for missing values

      return BarChartGroupData(
        x: monthIndex,
        barRods: [
          BarChartRodData(
            toY: usage,
            color: barColor,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return BarChartData(
      barGroups: barGroups,
      alignment: BarChartAlignment.spaceEvenly,
      maxY: maxY,
      minY: 0,
      gridData: FlGridData(
        show: true,
        horizontalInterval: interval,
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 1,
            getTitlesWidget: (value, meta) {
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
              if (value.toInt() >= 0 && value.toInt() < months.length) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    months[value.toInt()],
                    style: TextStyle(fontSize: 10),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: interval,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}',
                style: TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final monthIndex = group.x.toInt();
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

            return BarTooltipItem(
              '$monthName $selectedYear\n',
              TextStyle(color: Colors.white),
              children: [
                TextSpan(
                  text: '${rod.toY.toStringAsFixed(2)} $unit',
                  style: TextStyle(
                    color: Colors.yellowAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Utility function to round up to the nearest interval
  double getRoundedMaxForMeter(
      List<Map<String, dynamic>> data, double interval) {
    double maxY = 0.0;

    for (var entry in data) {
      final usage = entry['usage'];
      if (usage != null && usage > maxY) {
        maxY = usage.toDouble();
      }
    }

    return ((maxY / interval).ceil() * interval)
        .toDouble(); // Round to the nearest interval
  }

  /// Dynamically calculate Y-axis interval based on max usage
  double _getYInterval(List<Map<String, dynamic>> data) {
    double maxY = 0.0;

    for (var entry in data) {
      final usage = entry['usage'];
      if (usage != null && usage > maxY) {
        maxY = usage.toDouble();
      }
    }

    // Determine interval based on maxY
    if (maxY <= 10) {
      return 1.0;
    } else if (maxY <= 50) {
      return 5.0;
    } else if (maxY <= 100) {
      return 10.0;
    } else if (maxY <= 500) {
      return 50.0;
    } else if (maxY <= 1000) {
      return 100.0;
    } else {
      return 200.0;
    }
  }
}
