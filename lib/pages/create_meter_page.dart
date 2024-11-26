import 'package:beaver_meter/constants/config.dart';
import 'package:beaver_meter/database_helper.dart';
import 'package:beaver_meter/models/meter.dart';
import 'package:flutter/material.dart';

class CreateMeterPage extends StatefulWidget {
  @override
  _CreateMeterPageState createState() => _CreateMeterPageState();
}

class _CreateMeterPageState extends State<CreateMeterPage> {
  final TextEditingController nameController = TextEditingController();

  String? selectedUnit;
  int? selectedColorId; // Updated to store the color ID
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
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Color'),
              value: selectedColorId,
              items: meterColorsMap.entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        color: entry.value,
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (int? newColorId) {
                setState(() {
                  selectedColorId = newColorId;
                });
              },
            ),
            SizedBox(height: 20),
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

                if ([meterName, selectedUnit, selectedColorId, selectedIcon]
                        .contains(null) ||
                    meterName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All fields must be filled.')),
                  );
                  return;
                }

                bool nameExists =
                    await DatabaseHelper().meterNameExists(meterName);

                if (nameExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Meter with that name already exists. Please choose a different name.')),
                  );
                } else {
                  // Create Meter object
                  final meter = Meter(
                    name: meterName,
                    unit: selectedUnit!,
                    color: selectedColorId!, // Store color id
                    icon: selectedIcon!.codePoint,
                  );

                  // Insert Meter into the database
                  await DatabaseHelper().insertMeter(meter);

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
