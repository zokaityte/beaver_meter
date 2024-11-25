import 'package:flutter/material.dart';
import '../models/price.dart';
import '../database_helper.dart';

class EditPricePage extends StatelessWidget {
  final Price price;

  EditPricePage({required this.price, Key? key}) : super(key: key);

  final TextEditingController pricePerUnitController = TextEditingController();
  final TextEditingController basePriceController = TextEditingController();
  final TextEditingController validFromController = TextEditingController();
  final TextEditingController validToController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Prefill controllers with existing price data
    pricePerUnitController.text = price.pricePerUnit.toString();
    basePriceController.text = price.basePrice.toString();
    validFromController.text = price.validFrom;
    validToController.text = price.validTo;

    return Scaffold(
      appBar: AppBar(title: Text('Edit Price')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: pricePerUnitController,
                decoration: InputDecoration(labelText: 'Price per Unit'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: basePriceController,
                decoration: InputDecoration(labelText: 'Base Price'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: validFromController,
                decoration: InputDecoration(labelText: 'Valid From'),
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 10),
              TextField(
                controller: validToController,
                decoration: InputDecoration(labelText: 'Valid To'),
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Save the updated price
                  final updatedPrice = Price(
                    id: price.id,
                    meterId: price.meterId,
                    pricePerUnit: double.tryParse(pricePerUnitController.text) ?? 0.0,
                    basePrice: double.tryParse(basePriceController.text) ?? 0.0,
                    validFrom: validFromController.text,
                    validTo: validToController.text,
                  );

                  await DatabaseHelper().updatePrice(updatedPrice); // Update price in the database

                  Navigator.pop(context); // Return the updated price to the parent
                },
                child: Text('Save Changes'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Delete the price
                  Navigator.pop(context, {'action': 'delete'});
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Delete Price'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
