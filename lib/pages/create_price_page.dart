import 'package:flutter/material.dart';
import 'package:beaver_meter/database_helper.dart';

class CreatePricePage extends StatelessWidget {
  final TextEditingController pricePerUnitController = TextEditingController();
  final TextEditingController basePriceController = TextEditingController();
  final TextEditingController validFromController = TextEditingController();
  final TextEditingController validToController = TextEditingController();

  final int meterId; // Pass the meter ID when creating a price

  CreatePricePage({Key? key, required this.meterId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Price')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: pricePerUnitController,
              decoration: const InputDecoration(labelText: 'Price per Unit'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: basePriceController,
              decoration: const InputDecoration(labelText: 'Base Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: validFromController,
              decoration: const InputDecoration(labelText: 'Valid From'),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: validToController,
              decoration: const InputDecoration(labelText: 'Valid To'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Gather data from input fields
                double? pricePerUnit = double.tryParse(pricePerUnitController.text);
                double? basePrice = double.tryParse(basePriceController.text);
                String validFrom = validFromController.text;
                String validTo = validToController.text;

                // Validate input
                if (pricePerUnit == null || basePrice == null || validFrom.isEmpty || validTo.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields with valid values.')),
                  );
                  return;
                }

                // Create price record
                Map<String, dynamic> price = {
                  'price_per_unit': pricePerUnit,
                  'base_price': basePrice,
                  'valid_from': validFrom,
                  'valid_to': validTo,
                  'meter_id': meterId,
                };

                // Insert into database
                int result = await DatabaseHelper().insertPrice(price);

                if (result != -1) {
                  // Success
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Price created successfully!')),
                  );
                  Navigator.pop(context);
                } else {
                  // Error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to create price. Please try again.')),
                  );
                }
              },
              child: const Text('Save Price'),
            ),
          ],
        ),
      ),
    );
  }
}
