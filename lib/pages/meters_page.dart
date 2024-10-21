import 'package:flutter/material.dart';
import 'create_meter_page.dart';
import 'meter_detail_page.dart';

class MetersPage extends StatelessWidget {
  final List<Map<String, dynamic>> meters = [
    {'name': 'Electricity', 'icon': Icons.bolt, 'color': const Color.fromARGB(255, 173, 134, 5), 'lastReading': 'Oct 1, 2024'},
    {'name': 'Water', 'icon': Icons.water, 'color': const Color.fromARGB(255, 84, 107, 126), 'lastReading': 'Sep 29, 2024'},
    {'name': 'Gas', 'icon': Icons.fireplace, 'color': const Color.fromARGB(255, 207, 97, 46), 'lastReading': 'Sep 30, 2024'},
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
        backgroundColor: const Color.fromARGB(255, 157, 184, 177),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateMeterPage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
