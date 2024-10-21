import 'package:flutter/material.dart';

class CreateMeterPage extends StatefulWidget {
  @override
  _CreateMeterPageState createState() => _CreateMeterPageState();
}

class _CreateMeterPageState extends State<CreateMeterPage> {
  final TextEditingController nameController = TextEditingController();

  // List of predefined units
  final List<String> units = ['kWh', 'm³', 'liters', 'gallons'];
  String? selectedUnit;

  // List of colors
  final List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.orange];
  Color? selectedColor;

  // List of icons
  final List<IconData> icons = [Icons.electric_bolt, Icons.water, Icons.fireplace, Icons.bolt];
  IconData? selectedIcon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Meter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Meter Name'),
            ),
            SizedBox(height: 20),
            // Dropdown for selecting units
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Units'),
              value: selectedUnit,
              items: units.map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedUnit = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            // Dropdown for selecting color
            DropdownButtonFormField<Color>(
              decoration: InputDecoration(labelText: 'Color'),
              value: selectedColor,
              items: colors.map((Color color) {
                return DropdownMenuItem<Color>(
                  value: color,
                  child: Container(
                    width: 24,
                    height: 24,
                    color: color,
                  ),
                );
              }).toList(),
              onChanged: (Color? newColor) {
                setState(() {
                  selectedColor = newColor;
                });
              },
            ),
            SizedBox(height: 20),
            // Dropdown for selecting icon
            DropdownButtonFormField<IconData>(
              decoration: InputDecoration(labelText: 'Icon'),
              value: selectedIcon,
              items: icons.map((IconData icon) {
                return DropdownMenuItem<IconData>(
                  value: icon,
                  child: Icon(icon),
                );
              }).toList(),
              onChanged: (IconData? newIcon) {
                setState(() {
                  selectedIcon = newIcon;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save the meter data here
                final meterData = {
                  'name': nameController.text,
                  'unit': selectedUnit,
                  'color': selectedColor,
                  'icon': selectedIcon,
                };

                // Log or save meterData
                print(meterData);

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
