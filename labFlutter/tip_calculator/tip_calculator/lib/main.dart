import 'package:flutter/material.dart';

void main() {
  runApp(const TipCalculatorApp());
}

class TipCalculatorApp extends StatelessWidget {
  const TipCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TipCalculator(),
    );
  }
}

class TipCalculator extends StatefulWidget {
  const TipCalculator({super.key});

  @override
  State<TipCalculator> createState() => _TipCalculatorState();
}

class _TipCalculatorState extends State<TipCalculator> {
  double _billAmount = 0;
  int _tipPercentage = 20;
  int _personCount = 1;

  @override
  Widget build(BuildContext context) {
    double tipAmount = _billAmount * (_tipPercentage / 100);
    double totalCost = _billAmount + tipAmount;
    double perPerson = _personCount > 0 ? totalCost / _personCount : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kalkulator Napiwków"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.lightGreen[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Tyle płaci każda osoba:",
                      style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      perPerson.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                elevation: 2,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.attach_money, color: Colors.blue),
                          labelText: "Do zapłaty",
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _billAmount = double.tryParse(value) ?? 0;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Liczba osób", style: TextStyle(fontSize: 16)),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (_personCount > 1) {
                                    setState(() {
                                      _personCount--;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.remove, color: Colors.green),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text("$_personCount", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 15),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _personCount++;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.add, color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Cały napiwek", style: TextStyle(fontSize: 16)),
                          Text(
                            "${tipAmount.toStringAsFixed(2)} zł",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "$_tipPercentage%",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      Slider(
                        min: 0,
                        max: 100,
                        activeColor: Colors.green,
                        inactiveColor: Colors.lightGreenAccent,
                        divisions: 10,
                        value: _tipPercentage.toDouble(),
                        onChanged: (double value) {
                          setState(() {
                            _tipPercentage = value.round();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
