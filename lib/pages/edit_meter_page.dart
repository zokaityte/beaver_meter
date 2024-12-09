import 'package:flutter/material.dart';
import 'package:beaver_meter/constants/config.dart';
import 'package:beaver_meter/database_helper.dart';
import 'package:beaver_meter/models/meter.dart';

class EditMeterPage extends StatefulWidget {
  final Meter meter;

  EditMeterPage({required this.meter});

  @override
  _EditMeterPageState createState() => _EditMeterPageState();
}

class _EditMeterPageState extends State<EditMeterPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String selectedUnit;
  late int selectedColorId; // Store color ID directly
  late IconData selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.meter.name);
    selectedUnit = widget.meter.unit;

    // Use color ID from the database directly
    selectedColorId = widget.meter.color;

    selectedIcon = IconData(widget.meter.icon, fontFamily: 'MaterialIcons');
  }

  Future<void> _updateMeter() async {
    if (_formKey.currentState!.validate()) {
      final db = DatabaseHelper();
      final updatedMeter = Meter(
        id: widget.meter.id,
        name: _nameController.text,
        unit: selectedUnit,
        color: selectedColorId, // Save color ID directly
        icon: selectedIcon.codePoint,
      );

      await db.updateMeter(updatedMeter.id!, updatedMeter.toMap());
      Navigator.pop(
          context, true); // Return to the previous screen with success
    }
  }

  Future<void> _deleteMeter() async {
    final db = DatabaseHelper();

    // Confirm deletion
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Meter'),
        content: Text(
            'Are you sure you want to delete this meter? All associated data will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await db.deleteMeter(
          widget.meter.id!); // Delete the meter and its associated data
      Navigator.popUntil(
          context, (route) => route.isFirst); // Back to MetersPage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Meter'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteMeter, // Trigger delete action
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Meter Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a meter name';
                  }
                  return null;
                },
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
                    selectedUnit = newValue!;
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
                        SizedBox(width: 8)
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (int? newColorId) {
                  setState(() {
                    selectedColorId = newColorId!;
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
                    selectedIcon = newIcon!;
                  });
                },
              ),
              SizedBox(height: 20),
              FilledButton(
                onPressed: _updateMeter,
                child: Text('Update Meter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
