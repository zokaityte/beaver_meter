import 'package:flutter/material.dart';
import 'create_meter_page.dart';
import 'meter_detail_page.dart';
import 'package:beaver_meter/database_helper.dart';

class MetersPage extends StatefulWidget {
  @override
  _MetersPageState createState() => _MetersPageState();
}

class _MetersPageState extends State<MetersPage> {
  late Future<List<Map<String, dynamic>>> metersFuture;

  @override
  void initState() {
    super.initState();
    _loadMeters(); // Initial load
  }

  // Load meters from the database
  void _loadMeters() {
    setState(() {
      metersFuture = DatabaseHelper().getMeters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
            return Center(child: Text('No meters found. Add one using the button below.'));
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
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MeterDetailPage(meter: meter),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(meter['color']), // Assuming 'color' is stored as ARGB int
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(IconData(meter['icon'], fontFamily: 'MaterialIcons'), size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text(meter['name'], style: TextStyle(fontSize: 20, color: Colors.white)),
                      SizedBox(height: 10),
                      Text('Last reading: ${meter['lastReading'] ?? 'N/A'}', style: TextStyle(fontSize: 14, color: Colors.white)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 157, 184, 177),
        onPressed: () async {
          // Navigate to CreateMeterPage and refresh when returning
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateMeterPage()),
          );
          _loadMeters(); // Reload meters when returning
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
