import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class PublicProfileFrame extends StatelessWidget {
  const PublicProfileFrame({super.key});

  @override
  Widget build(BuildContext context) {
    final String agentEmail = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text("Agent Profile")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(agentEmail).get(),
        builder: (context, userSnap) {
          if (!userSnap.hasData) return const Center(child: CircularProgressIndicator());
          var userData = userSnap.data!.data() as Map<String, dynamic>;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('tokens')
              .where('agentEmail', isEqualTo: agentEmail).snapshots(),
            builder: (context, tokenSnap) {
              if (!tokenSnap.hasData) return const Center(child: CircularProgressIndicator());
              
              var tokens = tokenSnap.data!.docs;
              int approved = tokens.where((t) => t['overallStatus'] == 'Approved').length;
              int cancelled = tokens.where((t) => t['overallStatus'] == 'Rejected').length;

              // Contribution Chart Data
              Map<DateTime, int> heatMapData = {};
              for (var doc in tokens) {
                Timestamp? ts = doc['createdAt'];
                if (ts != null) {
                  var date = DateTime(ts.toDate().year, ts.toDate().month, ts.toDate().day);
                  heatMapData[date] = (heatMapData[date] ?? 0) + 1;
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userData['businessName'] ?? userData['name'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const Text("Active Travel Agent", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        _statsCard("Total Tokens", tokens.length.toString()),
                        _statsCard("Approved", approved.toString()),
                        _statsCard("Cancelled", cancelled.toString()),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text("Booking Activity", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    HeatMap(
                      datasets: heatMapData,
                      colorMode: ColorMode.opacity,
                      colorsets: const { 1: Colors.grey },
                      showText: false,
                      scrollable: true,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statsCard(String title, String val) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(children: [Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(title, style: const TextStyle(fontSize: 12))]),
      ),
    ),
  );
}