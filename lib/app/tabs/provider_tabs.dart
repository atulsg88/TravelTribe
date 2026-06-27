import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderHome extends StatelessWidget {
  final String userRole;
  final String providerEmail;
  const ProviderHome({super.key, required this.userRole, required this.providerEmail});

  @override
  Widget build(BuildContext context) {
    String statusField = (userRole == "Hotelier") ? 'hotelStatus' : 'cabStatus';
    String otherStatusField = (userRole == "Hotelier") ? 'cabStatus' : 'hotelStatus';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tokens')
          .where(userRole == "Hotelier" ? 'hotelEmail' : 'cabEmail', isEqualTo: providerEmail).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        // Sort by createdAt descending (latest first)
        var docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          var dataA = a.data() as Map<String, dynamic>;
          var dataB = b.data() as Map<String, dynamic>;
          Timestamp? tsA = dataA['createdAt'];
          Timestamp? tsB = dataB['createdAt'];
          if (tsA == null && tsB == null) return 0;
          if (tsA == null) return 1;
          if (tsB == null) return -1;
          return tsB.compareTo(tsA);
        });
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            var doc = docs[i];
            var data = doc.data() as Map<String, dynamic>;

            return Card(
              child: ListTile(
                title: Text("Request from: ${data['agentBusiness'] ?? data['agentEmail']}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Agent Phone: ${data['agentPhone'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    // FIXED: Show only the requirement matching the current provider's role
                    Text(userRole == "Hotelier" 
                        ? "Hotel Requirement: ${data['hotelType']}" 
                        : "Cab Requirement: ${data['cabType']}"),
                  ],
                ),
                trailing: data[statusField] == 'Pending' 
                  ? Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () async {
                        await doc.reference.update({statusField: 'Approved'});
                        var fresh = await doc.reference.get();
                        if (fresh[otherStatusField] == 'Approved') {
                          await doc.reference.update({'overallStatus': 'Approved'});
                        }
                      }),
                      IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () {
                        doc.reference.update({statusField: 'Rejected', 'overallStatus': 'Rejected'});
                      }),
                    ])
                  : Text(data[statusField], style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }
}