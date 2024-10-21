import 'package:flutter/material.dart';

class CreateMeterPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController unitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Meter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Meter Name')),
            TextField(controller: unitController, decoration: InputDecoration(labelText: 'Units')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save the meter here
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
