import 'package:beaver_meter/constants/config.dart';
import 'package:beaver_meter/database_helper.dart';
import 'package:flutter/material.dart';

class CreateMeterPage extends StatefulWidget {
  @override
  _CreateMeterPageState createState() => _CreateMeterPageState();
}

class _CreateMeterPageState extends State<CreateMeterPage> {
  final TextEditingController nameController = TextEditingController();

  String? selectedUnit;
  Color? selectedColor;
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
              items: meterColors.map((Color color) {
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
              items: meterIcons.map((IconData icon) {
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
              onPressed: () async {
                String meterName = nameController.text;

                if ([meterName, selectedUnit, selectedColor, selectedIcon].contains(null) || meterName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All fields must be filled.')),
                  );
                  return;
                }

                bool nameExists = await DatabaseHelper().meterNameExists(meterName);

                if (nameExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Meter with that name already exists. Please choose a different name.')),
                  );
                } else {
                  final meterData = {
                    'name': meterName,
                    'unit': selectedUnit,
                    'color': selectedColor?.value,
                    'icon': selectedIcon?.codePoint,
                  };

                  await DatabaseHelper().insertMeter(meterData);
                  print(meterData);

                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}