import 'package:flutter/material.dart';
import 'package:beaver_meter/database_helper.dart';
import 'package:beaver_meter/models/reading.dart';
import 'package:beaver_meter/models/meter.dart';
import 'package:beaver_meter/pages/edit_reading_page.dart'; // Import the EditReadingPage

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> readingsWithMeterData = [];
  List<Meter> meters = []; // List of meters for the dropdown
  Meter? selectedMeter; // Currently selected meter (null for "All Meters")
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMeters();
    _fetchReadingsWithMeterData();
  }

  Future<void> _fetchMeters() async {
    try {
      // Fetch all meters
      final fetchedMeters = await DatabaseHelper().getMeters();
      if (mounted) {
        setState(() {
          meters = fetchedMeters;
        });
      }
    } catch (e) {
      print('Error fetching meters: $e');
    }
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

  List<Map<String, dynamic>> _filterReadingsByMeter() {
    if (selectedMeter == null) {
      return readingsWithMeterData; // Show all readings if no meter is selected
    }
    return readingsWithMeterData
        .where((readingData) => readingData['meter'].id == selectedMeter!.id)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredReadings = _filterReadingsByMeter();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<Meter>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Filter by Meter',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              value: selectedMeter,
              items: [
                DropdownMenuItem<Meter>(
                  value: null, // For "All Meters"
                  child: Row(
                    children: [
                      Icon(Icons.all_inclusive),
                      SizedBox(width: 8),
                      Text('All Meters'),
                    ],
                  ),
                ),
                ...meters.map((meter) {
                  return DropdownMenuItem<Meter>(
                    value: meter,
                    child: Row(
                      children: [
                        Icon(IconData(meter.icon, fontFamily: 'MaterialIcons')),
                        SizedBox(width: 8),
                        Text(meter.name),
                      ],
                    ),
                  );
                }).toList(),
              ],
              onChanged: (Meter? newMeter) {
                setState(() {
                  selectedMeter = newMeter;
                });
              },
            ),
          ),
          Expanded(
            child: filteredReadings.isEmpty
                ? Center(child: Text('No readings available for the selected meter.'))
                : ListView.builder(
              itemCount: filteredReadings.length,
              itemBuilder: (context, index) {
                final readingData = filteredReadings[index];
                final Reading reading = readingData['reading'];
                final Meter meter = readingData['meter'];
                final previousReading = index < filteredReadings.length - 1
                    ? filteredReadings[index + 1]['reading']
                    : null;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8.0),
                    title: Text(
                      '${meter.name}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Value: ${reading.value} ${meter.unit}'),
                        Text('Date: ${reading.date}'),
                        if (previousReading != null)
                          Text(
                            calculateConsumption(
                              reading.value.toString(),
                              previousReading.value.toString(),
                              meter.unit,
                            ),
                            style: TextStyle(color: Colors.green),
                          ),
                      ],
                    ),
                    onTap: () async {
                      // Navigate to the EditReadingPage and refresh data upon returning
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditReadingPage(reading: reading),
                        ),
                      );
                      if (result == 'refresh') {
                        _fetchReadingsWithMeterData(); // Refresh data
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
