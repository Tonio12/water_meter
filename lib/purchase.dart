import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PurchaseCredit extends StatefulWidget {
  const PurchaseCredit({super.key});

  @override
  State<StatefulWidget> createState() {
    return PurchaseCreditState();
  }
}

class PurchaseCreditState extends State<PurchaseCredit> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _meterNumber = '';
  double _creditAmount = 0.0;

  void _saveItem() async {
    String message = '"Puchase Successful. Thank You!!!"';
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.https('water-meter-bff34-default-rtdb.firebaseio.com',
          'meters/$_meterNumber.json');
      print(url);
      try {
        var meterData = await http.get(
          url,
          headers: {'Content-Type': 'application/json'},
        );

        final balance = json.decode(meterData.body)['balance'] ?? 0.0;
        var response = await http.put(url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'customerName': _name,
              'balance': balance + _creditAmount,
            }));

        print(response.body);

        if (response.statusCode >= 400) {
          message = 'An Error Occured. Please Try Again';
        }

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      } catch (err) {
        print(err);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("error Purchasing credit")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Puchase Credit"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(label: Text('Customer Name')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Your Name';
                  }

                  return null;
                },
                onSaved: (newValue) {
                  setState(() {
                    _name = newValue ?? '';
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(label: Text('Meter Number')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Your Name';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  setState(() {
                    _meterNumber = newValue ?? '';
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration:
                    const InputDecoration(label: Text('Enter amount in GHS')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Your Name';
                  }

                  return null;
                },
                onSaved: (newValue) {
                  setState(() {
                    _creditAmount = double.parse(newValue!);
                  });
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saveItem,
                child: const Text("Buy"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
