import 'package:flutter/material.dart';

class PublicHomeFrame extends StatelessWidget {
  const PublicHomeFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Travel Trust"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(onPressed: () => Navigator.pushNamed(context, '/search'), child: const Text("Search Agents")),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero Section
            Container(
              height: 400,
              padding: const EdgeInsets.all(40),
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Verified travel bookings you can trust", 
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {}, 
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("Download App", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            // 2. How It Works
            _sectionTitle("How It Works"),
            _stepTile("Step 1", "Agent requests token"),
            _stepTile("Step 2", "Hotel/Cab approves"),
            _stepTile("Step 3", "Customer verifies"),
            const SizedBox(height: 40),
            // 3. Why Trust Us
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  _sectionTitle("Why Trust Us"),
                  _trustPoint(Icons.shield, "Fraud prevention"),
                  _trustPoint(Icons.check_circle, "Transparent confirmation"),
                  _trustPoint(Icons.money_off, "No payment handling"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.all(20),
    child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
  );

  Widget _stepTile(String step, String desc) => ListTile(
    leading: CircleAvatar(backgroundColor: Colors.black, child: Text(step.split(' ')[1], style: const TextStyle(color: Colors.white))),
    title: Text(desc),
  );

  Widget _trustPoint(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
    child: Row(children: [Icon(icon), const SizedBox(width: 20), Text(text)]),
  );
}