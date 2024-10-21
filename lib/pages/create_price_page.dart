import 'package:flutter/material.dart';

class CreatePricePage extends StatelessWidget {
  final TextEditingController pricePerUnitController = TextEditingController();
  final TextEditingController basePriceController = TextEditingController();
  final TextEditingController validFromController = TextEditingController();
  final TextEditingController validToController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Price')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: pricePerUnitController, decoration: InputDecoration(labelText: 'Price per Unit')),
            TextField(controller: basePriceController, decoration: InputDecoration(labelText: 'Base Price')),
            TextField(controller: validFromController, decoration: InputDecoration(labelText: 'Valid From')),
            TextField(controller: validToController, decoration: InputDecoration(labelText: 'Valid To')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save the price and assign it to the current meter
                Navigator.pop(context);
              },
              child: Text('Save Price'),
            ),
          ],
        ),
      ),
    );
  }
}
