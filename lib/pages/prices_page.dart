import 'package:flutter/material.dart';
import 'create_price_page.dart'; // To create a new price
import 'edit_price_page.dart';   // To edit an existing price
import '../models/price.dart';   // Import Price model
import '../models/meter.dart';   // Import Meter model
import 'package:beaver_meter/database_helper.dart';

class PricesPage extends StatefulWidget {
  final Meter meter;

  PricesPage({required this.meter});

  @override
  _PricesPageState createState() => _PricesPageState();
}

class _PricesPageState extends State<PricesPage> {
  List<Price> prices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load prices for the given meter
  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    final fetchedPrices = await DatabaseHelper().getPricesByMeterIdAsObjects(widget.meter.id!);

    setState(() {
      prices = fetchedPrices;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Prices for ${widget.meter.name}')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Prices for ${widget.meter.name}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: prices.length,
              itemBuilder: (context, index) {
                final price = prices[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('Price: \$${price.pricePerUnit} per ${widget.meter.unit}'),
                    subtitle: Text(
                      'Base Price: \$${price.basePrice}\nValid from: ${price.validFrom} to ${price.validTo}',
                    ),
                    onTap: () async {
                      // Navigate to the Edit Price Page and refresh upon returning
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPricePage(price: price, unit: widget.meter.unit),
                        ),
                      );
                      if (result != null) {
                        _loadData(); // Refresh prices after returning
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.blue,
              child: ListTile(
                leading: Icon(Icons.add, color: Colors.white),
                title: Text(
                  'Add Price',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  // Navigate to the Create Price Page and refresh when returning
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatePricePage(meterId: widget.meter.id!, unit: widget.meter.unit),
                    ),
                  );
                  _loadData(); // Refresh prices
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
