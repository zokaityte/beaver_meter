import 'package:beaver_meter/constants/config.dart'; // Import the color map
import 'package:beaver_meter/models/meter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database_helper.dart';
import '../providers/settings_provider.dart';
import 'create_reading_page.dart'; // Import the Create Reading Page
import 'edit_meter_page.dart';
import 'prices_page.dart'; // Import the Prices Page

class MeterDetailPage extends StatefulWidget {
  final Meter meter;

  MeterDetailPage({required this.meter});

  @override
  _MeterDetailPageState createState() => _MeterDetailPageState();
}

class _MeterDetailPageState extends State<MeterDetailPage> {
  late Meter meter;
  int? lastMonthUsage;
  double? lastMonthCost;
  String? lastMonth; // To store the month as a string, e.g., "2024-10"

  @override
  void initState() {
    super.initState();
    meter = widget.meter;
    _fetchLastMonthData();
  }

  Future<void> _fetchLastMonthData() async {
    // Fetch data for the specific meter
    final dataList =
        await DatabaseHelper().getMonthlyUsageAndCost(meterId: meter.id);

    if (dataList.isNotEmpty) {
      // Directly get the first entry as the last data point
      final data = dataList.last;

      setState(() {
        lastMonthUsage = data['monthly_usage'] as int;
        lastMonthCost = data['total_cost'] as double;
        lastMonth = data['month'] as String;
      });
    } else {
      // No data available
      setState(() {
        lastMonthUsage = null;
        lastMonthCost = null;
        lastMonth = null;
      });
    }
  }

  Future<void> _reloadDetails() async {
    final updatedMeter = await DatabaseHelper().getMeterById(meter.id!);
    if (updatedMeter != null) {
      setState(() {
        meter = updatedMeter;
      });
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = context.watch<SettingsProvider>().currencySymbol;
    final String meterName = meter.name;
    final IconData meterIcon =
        IconData(meter.icon, fontFamily: 'MaterialIcons');
    final String meterUnit = meter.unit;

    // Fetch the color from the map using the color ID
    final Color meterColor =
        meterColorsMap[meter.color] ?? const Color(0xFF000000);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: meterColor,
        title: Row(
          children: [
            Icon(meterIcon, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text(
              meterName,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.electric_meter,
                              color: Colors.blue, size: 40),
                          SizedBox(height: 10),
                          Text(
                            lastMonthUsage != null
                                ? '$lastMonthUsage $meterUnit'
                                : 'N/A',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            lastMonth != null
                                ? 'Usage for $lastMonth'
                                : 'Last Month Usage',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.credit_card,
                              color: Colors.green, size: 40),
                          SizedBox(height: 10),
                          Text(
                            lastMonthCost != null
                                ? '$currencySymbol ${lastMonthCost!.toStringAsFixed(2)}'
                                : 'N/A',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            lastMonth != null
                                ? 'Cost for $lastMonth'
                                : 'Last Month Cost',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Display actionable panels in a column (selectable)
            Card(
              child: ListTile(
                leading: Icon(Icons.money, color: Colors.orange),
                title: Text('Prices'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PricesPage(meter: meter), // Pass meter ID
                    ),
                  );
                  await _fetchLastMonthData();
                },
              ),
            ),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Icon(Icons.add, color: Colors.blue),
                title: Text('Add Reading'),
                onTap: () async {
                  // Navigate to CreateReadingPage
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateReadingPage(
                          meterId: meter.id!), // Pass meter ID
                    ),
                  );
                  await _fetchLastMonthData();
                },
              ),
            ),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Icon(Icons.edit, color: Colors.red),
                title: Text('Edit Meter'),
                onTap: () async {
                  bool? updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditMeterPage(meter: meter), // Pass the Meter object
                    ),
                  );
                  if (updated == true) {
                    await _reloadDetails();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
