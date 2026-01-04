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
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            var doc = snapshot.data!.docs[i];
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