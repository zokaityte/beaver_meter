import 'package:flutter/material.dart';
import 'pages/meters_page.dart';
import 'pages/trends_page.dart';
import 'pages/history_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
    MetersPage(),
    HistoryPage(),
    TrendsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeaverMeter',
      theme: ThemeData(
        primarySwatch: Colors.blue,

      ),
      home: Scaffold(
        appBar: AppBar(title: Text('BeaverMeter'), backgroundColor: const Color.fromARGB(255, 122, 176, 184)),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.blue,  // Set background color for the bar
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.electric_meter),
              label: 'Meters',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Trends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(255, 122, 176, 184),   // Selected item color white
          unselectedItemColor: const Color.fromARGB(255, 201, 201, 201),  // Unselected items in grey
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
