import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  // Dummy data for readings with meter names and values as Strings
  final List<Map<String, dynamic>> readings = [
    {'meterName': 'Electricity', 'date': 'Oct 1, 2024', 'value': '1000', 'unit': 'kWh'},
    {'meterName': 'Electricity', 'date': 'Sep 29, 2024', 'value': '950', 'unit': 'kWh'},
    {'meterName': 'Water', 'date': 'Sep 25, 2024', 'value': '900', 'unit': 'm³'},
    {'meterName': 'Water', 'date': 'Sep 20, 2024', 'value': '850', 'unit': 'm³'},
  ];

  // Function to calculate the consumption difference
  String calculateConsumption(String currentValueStr, String? previousValueStr, String unit) {
    // Ensure both values are not null
    if (currentValueStr == null || previousValueStr == null) {
      return 'No previous data';
    }

    int currentValue = int.tryParse(currentValueStr) ?? 0; // Convert current value to int
    int previousValue = int.tryParse(previousValueStr) ?? 0; // Convert previous value to int

    int consumption = currentValue - previousValue;
    return '$consumption $unit consumed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: readings.length,
        itemBuilder: (context, index) {
          final reading = readings[index];
          final previousReading = index < readings.length - 1
              ? readings[index + 1] // Get the previous reading (if exists)
              : null;

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text('${reading['meterName']} - ${reading['value']} ${reading['unit']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${reading['date']}'),
                  if (previousReading != null && previousReading['value'] != null)
                    Text(
                      calculateConsumption(reading['value'], previousReading['value'], reading['unit']),
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
