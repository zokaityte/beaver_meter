import 'package:flutter/material.dart';
import '../models/meter.dart';
import 'create_meter_page.dart';
import 'meter_detail_page.dart';
import 'package:beaver_meter/database_helper.dart';
import 'package:beaver_meter/constants/config.dart'; // Import the color map

class MetersPage extends StatefulWidget {
  @override
  _MetersPageState createState() => _MetersPageState();
}

class _MetersPageState extends State<MetersPage> {
  late Future<List<Meter>> metersFuture;

  @override
  void initState() {
    super.initState();
    _loadMeters();
  }

  void _loadMeters() {
    setState(() {
      metersFuture = DatabaseHelper().getMeters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Meter>>(
        future: metersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching meters'));
          }

          final meters = snapshot.data ?? [];

          if (meters.isEmpty) {
            return Center(
                child: Text('No meters found. Add one using the button below.'));
          }

          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: meters.length,
            itemBuilder: (context, index) {
              final meter = meters[index];
              return FutureBuilder<String?>(
                future: DatabaseHelper().getLatestReadingDate(meter.id!),
                builder: (context, dateSnapshot) {
                  final lastReadingDate =
                      dateSnapshot.data ?? 'N/A'; // Default to 'N/A' if no data

                  // Get the color using the meter.color as an ID
                  final meterColor = meterColorsMap[meter.color];

                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MeterDetailPage(meter: meter),
                        ),
                      );
                      _loadMeters(); // Refresh list after returning
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: meterColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            IconData(meter.icon, fontFamily: 'MaterialIcons'),
                            size: 50,
                            color: Colors.white,
                          ),
                          SizedBox(height: 10),
                          Text(
                            meter.name,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Last reading: $lastReadingDate',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateMeterPage()),
          );
          _loadMeters(); // Refresh list after adding
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
