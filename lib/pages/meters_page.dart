import 'package:flutter/material.dart';
import 'create_meter_page.dart';
import 'meter_detail_page.dart';

class MetersPage extends StatelessWidget {
  final List<Map<String, dynamic>> meters = [
    {'name': 'Electricity', 'icon': Icons.bolt, 'color': Colors.yellow, 'lastReading': 'Oct 1, 2023'},
    {'name': 'Water', 'icon': Icons.water, 'color': Colors.blue, 'lastReading': 'Sep 29, 2023'},
    {'name': 'Gas', 'icon': Icons.fireplace, 'color': Colors.orange, 'lastReading': 'Sep 30, 2023'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: meters.length,
        itemBuilder: (context, index) {
          final meter = meters[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MeterDetailPage(meter: meter)));
            },
            child: Container(
              decoration: BoxDecoration(color: meter['color'], borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(meter['icon'], size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(meter['name'], style: TextStyle(fontSize: 20, color: Colors.white)),
                  SizedBox(height: 10),
                  Text('Last reading: ${meter['lastReading']}', style: TextStyle(fontSize: 14, color: Colors.white)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateMeterPage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
