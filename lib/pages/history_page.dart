import 'package:flutter/material.dart';
import 'package:beaver_meter/database_helper.dart';
import 'package:beaver_meter/models/reading.dart';
import 'package:beaver_meter/models/meter.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> readingsWithMeterData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReadingsWithMeterData();
  }

  Future<void> _fetchReadingsWithMeterData() async {
    try {
      // Fetch readings joined with meter data
      final fetchedReadings = await DatabaseHelper().getReadingsWithMeterData();
      if (mounted) {
        setState(() {
          readingsWithMeterData = fetchedReadings;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching readings: $e');
    }
  }

  String calculateConsumption(String currentValueStr, String? previousValueStr, String unit) {
    if (currentValueStr.isEmpty || previousValueStr == null || previousValueStr.isEmpty) {
      return 'No previous data';
    }

    int currentValue = int.tryParse(currentValueStr) ?? 0;
    int previousValue = int.tryParse(previousValueStr) ?? 0;

    int consumption = currentValue - previousValue;
    return '$consumption $unit consumed';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('History')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (readingsWithMeterData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('History')),
        body: Center(child: Text('No readings available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('History')),
      body: ListView.builder(
        itemCount: readingsWithMeterData.length,
        itemBuilder: (context, index) {
          final readingData = readingsWithMeterData[index];
          final Reading reading = readingData['reading'];
          final Meter meter = readingData['meter'];
          final previousReading = index < readingsWithMeterData.length - 1
              ? readingsWithMeterData[index + 1]['reading']
              : null;

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text('${meter.name} - ${reading.value} ${meter.unit}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${reading.date}'),
                  if (previousReading != null)
                    Text(
                      calculateConsumption(reading.value.toString(), previousReading.value.toString(), meter.unit),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
