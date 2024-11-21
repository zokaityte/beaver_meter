// lib/pages/edit_meter_page.dart
import 'package:flutter/material.dart';
import 'package:beaver_meter/database_helper.dart';

class EditMeterPage extends StatefulWidget {
  final int meterId;

  EditMeterPage({required this.meterId});

  @override
  _EditMeterPageState createState() => _EditMeterPageState();
}

class _EditMeterPageState extends State<EditMeterPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  late TextEditingController _colorController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _iconController = TextEditingController();
    _colorController = TextEditingController();
    _fetchMeterDetails();
  }

  Future<void> _fetchMeterDetails() async {
    final db = DatabaseHelper();
    final meter = await db.getMeterById(widget.meterId);

    if (meter != null) {
      setState(() {
        _nameController.text = meter['name'] ?? '';
        _iconController.text = meter['icon']?.toString() ?? '';
        _colorController.text = meter['color']?.toString() ?? '';
      });
    }
  }

  Future<void> _updateMeter() async {
    if (_formKey.currentState!.validate()) {
      final db = DatabaseHelper();
      await db.updateMeter(widget.meterId, {
        'name': _nameController.text,
        'icon': int.tryParse(_iconController.text) ?? 0,
        'color': int.tryParse(_colorController.text) ?? 0,
      });
      Navigator.pop(context, true); // Return to previous screen with success
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Meter'),
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
              TextFormField(
                controller: _iconController,
                decoration: InputDecoration(labelText: 'Icon Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an icon code';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _colorController,
                decoration: InputDecoration(labelText: 'Color Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a color code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateMeter,
                child: Text('Update Meter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}