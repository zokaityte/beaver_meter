import 'package:flutter/material.dart';
import 'package:beaver_meter/database_helper.dart';
import 'package:beaver_meter/models/meter.dart';
import 'package:beaver_meter/pages/edit_reading_page.dart';

import '../models/reading.dart';

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
      // Fetch readings with previous values included
      final fetchedReadings =
          await DatabaseHelper().getReadingsWithPreviousValues();
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

  List<Map<String, dynamic>> _filterReadingsByMeter() {
    if (selectedMeter == null) {
      return readingsWithMeterData; // Show all readings if no meter is selected
    }
    return readingsWithMeterData
        .where((readingData) => readingData['meter_id'] == selectedMeter!.id)
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
                ? Center(
                    child:
                        Text('No readings available for the selected meter.'))
                : ListView.builder(
                    itemCount: filteredReadings.length,
                    itemBuilder: (context, index) {
                      final readingData = filteredReadings[index];
                      final String meterName = readingData['meter_name'];
                      final String unit = readingData['meter_unit'];
                      final int currentValue = readingData['current_value'];
                      final int? previousValue = readingData['previous_value'];
                      final String date = readingData['current_date'];

                      return Card(
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(8.0),
                          title: Text(
                            meterName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Value: $currentValue $unit'),
                              Text('Date: $date'),
                              if (previousValue != null)
                                Text(
                                  '${currentValue - previousValue} $unit consumed',
                                  style: TextStyle(color: Colors.green),
                                )
                              else
                                Text(
                                  'No previous data',
                                  style: TextStyle(color: Colors.red),
                                ),
                            ],
                          ),
                          onTap: () async {
                            // Navigate to the EditReadingPage and refresh data upon returning
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditReadingPage(
                                  reading: Reading(
                                    id: readingData['reading_id'],
                                    meterId: readingData['meter_id'],
                                    value: currentValue,
                                    date: date,
                                  ),
                                ),
                              ),
                            );
                            await _fetchReadingsWithMeterData(); // Refresh data
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
