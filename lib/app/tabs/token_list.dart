import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class MyTokensList extends StatelessWidget {
  final String userEmail;
  final String role;
  const MyTokensList({super.key, required this.userEmail, required this.role});

  Future<void> _sendEmailLink(BuildContext context, String tokenId) async {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Send Link to Customer"),
        content: TextField(
          controller: emailCtrl, 
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: "Customer Email", hintText: "example@mail.com")
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String customerEmail = emailCtrl.text.trim();
              if (customerEmail.isEmpty) return;
              String webUrl = "https://traveltribe-7ddea.web.app/#/verify?id=$tokenId"; 
              String subject = Uri.encodeComponent("Booking Confirmation - Travel Trust");
              String body = Uri.encodeComponent("Hello, your booking is confirmed. View details here: \n\n$webUrl");
              final Uri mailUri = Uri.parse("mailto:$customerEmail?subject=$subject&body=$body");
              if (await canLaunchUrl(mailUri)) {
                await launchUrl(mailUri, mode: LaunchMode.externalApplication);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Open Mail App"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String queryField = (role == "Travel Agent") ? 'agentEmail' : (role == "Hotelier" ? 'hotelEmail' : 'cabEmail');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tokens').where(queryField, isEqualTo: userEmail).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No tokens found."));

        var docs = snapshot.data!.docs;
        Map<DateTime, int> heatMapData = {}; 
        for (var doc in docs) {
          var data = doc.data() as Map<String, dynamic>;
          Timestamp? ts = data['createdAt'];
          if (ts != null) {
            var date = DateTime(ts.toDate().year, ts.toDate().month, ts.toDate().day);
            heatMapData[date] = (heatMapData[date] ?? 0) + 1;
          }
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text("Contribution Activity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            HeatMap(
              datasets: heatMapData, 
              colorMode: ColorMode.opacity, 
              colorsets: const { 1: Colors.green }, 
              scrollable: true,
              showText: true, 
              textColor: Colors.black,
            ),
            const Divider(height: 40),
            const Text("Token History", style: TextStyle(fontWeight: FontWeight.bold)),
            ...docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              bool isSendable = data['hotelStatus'] == 'Approved' && data['cabStatus'] == 'Approved';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Status: ${data['overallStatus']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          if (role == "Travel Agent" && isSendable && data['overallStatus'] == 'Approved')
                            ElevatedButton(onPressed: () => _sendEmailLink(context, doc.id), child: const Text("SEND")),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // FIXED: Show status only for the current provider or show both for Agent
                      if (role == "Travel Agent") 
                        Text("Hotel: ${data['hotelStatus']} | Cab: ${data['cabStatus']}")
                      else if (role == "Hotelier")
                        Text("My Status: ${data['hotelStatus']}")
                      else
                        Text("My Status: ${data['cabStatus']}"),
                      const Divider(),
                      const Text("Contact & Business Info:", style: TextStyle(fontWeight: FontWeight.bold)),
                      // FIXED: Providers cannot see each other's details
                      if (role == "Travel Agent") ...[
                        Text("Hotel: ${data['hotelBusiness'] ?? 'N/A'}\nPhone: ${data['hotelPhone'] ?? 'N/A'}"),
                        Text("Cab: ${data['cabBusiness'] ?? 'N/A'}\nPhone: ${data['cabPhone'] ?? 'N/A'}"),
                      ] else if (role == "Hotelier") ...[
                        Text("Agent: ${data['agentBusiness'] ?? 'N/A'}"),
                        Text("Phone: ${data['agentPhone'] ?? 'N/A'}"),
                      ] else if (role == "Cab Driver") ...[
                        Text("Agent: ${data['agentBusiness'] ?? 'N/A'}"),
                        Text("Phone: ${data['agentPhone'] ?? 'N/A'}"),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}