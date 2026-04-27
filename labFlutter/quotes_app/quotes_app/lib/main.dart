import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: QuotesApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class QuotesApp extends StatefulWidget {
  const QuotesApp({super.key});

  @override
  State<QuotesApp> createState() => _QuotesAppState();
}

class _QuotesAppState extends State<QuotesApp> {
  List<String> quotes = [
    "Programowanie to w 10% pisanie kodu, a w 90% szukanie w nim błędu.",
    "Nie działa? Zresetuj. Dalej nie działa? Sprawdź logi.",
    "Zawsze pisz kod tak, jakby osobą która go będzie utrzymywać, był psychopata znający Twój adres domowy.",
    "Najlepszym przyjacielem programisty jest gumowa kaczuszka."
  ];
  int index = 0;

  void _showQuote() {
    setState(() {
      index = (index + 1) % quotes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("quotes app"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Spacer(),
            Text(
              quotes[index],
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            const Divider(),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _showQuote,
              style: TextButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.join_inner, color: Colors.black),
              label: const Text(
                "New Quote",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
