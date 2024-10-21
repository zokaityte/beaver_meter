import 'package:flutter/material.dart';

class EditPricePage extends StatelessWidget {
  final Map<String, dynamic> price;

  EditPricePage({required this.price});

  final TextEditingController pricePerUnitController = TextEditingController();
  final TextEditingController basePriceController = TextEditingController();
  final TextEditingController validFromController = TextEditingController();
  final TextEditingController validToController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Prefill controllers with existing price data
    pricePerUnitController.text = price['pricePerUnit'];
    basePriceController.text = price['basePrice'];
    validFromController.text = price['validFrom'];
    validToController.text = price['validTo'];

    return Scaffold(
      appBar: AppBar(title: Text('Edit Price')),
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
                // Save the updated price and link it back to the meter
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Delete the price
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // Fixed this line
              child: Text('Delete Price'),
            ),
          ],
        ),
      ),
    );
  }
}
