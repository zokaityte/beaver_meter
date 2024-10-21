import 'package:flutter/material.dart';
import 'create_price_page.dart'; // To create a new price
import 'edit_price_page.dart';   // To edit an existing price

class PricesPage extends StatelessWidget {
  final Map<String, dynamic> meter;

  PricesPage({required this.meter});

  // Dummy data for prices associated with the meter
  final List<Map<String, dynamic>> prices = [
    {'pricePerUnit': '0.12', 'basePrice': '5.00', 'validFrom': 'Jan 2023', 'validTo': 'Dec 2023'},
    {'pricePerUnit': '0.10', 'basePrice': '4.50', 'validFrom': 'Jan 2022', 'validTo': 'Dec 2022'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prices for ${meter['name']}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: prices.length,
              itemBuilder: (context, index) {
                final price = prices[index];
                return ListTile(
                  title: Text('Price: \$${price['pricePerUnit']} per unit'),
                  subtitle: Text('Base Price: \$${price['basePrice']}\nValid from: ${price['validFrom']} to ${price['validTo']}'),
                  onTap: () {
                    // Navigate to the Edit Price Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPricePage(price: price),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to the Create Price Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreatePricePage()),
              );
            },
            child: Text('Add Price'),
          ),
        ],
      ),
    );
  }
}
