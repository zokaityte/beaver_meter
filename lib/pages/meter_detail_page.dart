import 'package:flutter/material.dart';
import 'edit_meter_page.dart';
import 'prices_page.dart'; // Import the Prices Page
import 'create_reading_page.dart'; // Import the Create Reading Page
import 'package:beaver_meter/models/meter.dart';

class MeterDetailPage extends StatelessWidget {
  final Meter meter;

  MeterDetailPage({required this.meter});

  @override
  Widget build(BuildContext context) {
    final String meterName = meter.name;
    final IconData meterIcon = IconData(meter.icon, fontFamily: 'MaterialIcons');
    final Color meterColor = Color(meter.color); // Convert ARGB int to Color

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
            // Display averages in a row (information panels)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.electric_bolt, color: Colors.blue, size: 40),
                          SizedBox(height: 10),
                          Text('500 units', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Average Consumption'),
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
                          Icon(Icons.attach_money, color: Colors.green, size: 40),
                          SizedBox(height: 10),
                          Text('\$100', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Avg Price This Year'),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PricesPage(meterId: meter.id!), // Pass meter ID
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Icon(Icons.add, color: Colors.blue),
                title: Text('Add Reading'),
                onTap: () {
                  // Navigate to CreateReadingPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateReadingPage(meterId: meter.id!), // Pass meter ID
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Icon(Icons.edit, color: Colors.red),
                title: Text('Edit Meter'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMeterPage(meter: meter), // Pass the Meter object
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
