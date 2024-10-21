import 'package:flutter/material.dart';
import 'prices_page.dart'; // Import the Prices Page

class MeterDetailPage extends StatelessWidget {
  final Map<String, dynamic> meter;

  MeterDetailPage({required this.meter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(meter['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the average consumption data
            Text('Average Consumption (This Year): 500 units', style: TextStyle(fontSize: 18)),
            Text('Average Consumption in Price (This Year): \$100', style: TextStyle(fontSize: 18)),
            
            SizedBox(height: 20),
            
            // Add a "Prices" button that navigates to the Prices Page
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PricesPage(meter: meter), // Pass the meter details to the Prices Page
                  ),
                );
              },
              child: Text('View Prices'),
            ),
            
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // Add reading or navigate to add reading page
              },
              child: Text('Add Reading'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to Edit Meter Page
              },
              child: Text('Edit Meter'),
            ),
          ],
        ),
      ),
    );
  }
}
