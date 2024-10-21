import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final List<Map<String, String>> readings = [
    {'date': 'Oct 1, 2023', 'value': '1000 units'},
    {'date': 'Sep 29, 2023', 'value': '950 units'},
    {'date': 'Sep 25, 2023', 'value': '900 units'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: readings.length,
        itemBuilder: (context, index) {
          final reading = readings[index];
          return ListTile(
            title: Text(reading['value']!),
            subtitle: Text(reading['date']!),
          );
        },
      ),
    );
  }
}
