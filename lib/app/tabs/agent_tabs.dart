import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgentHome extends StatefulWidget {
  final String agentEmail;
  const AgentHome({super.key, required this.agentEmail});

  @override
  State<AgentHome> createState() => _AgentHomeState();
}

class _AgentHomeState extends State<AgentHome> {
  String? _selectedHotelEmail;
  String? _selectedCabEmail;

  void _showUnifiedForm() async {
    final roomTypeCtrl = TextEditingController();
    final carTypeCtrl = TextEditingController();
    DateTimeRange? selectedRange;

    var agentData = await FirebaseFirestore.instance.collection('users').doc(widget.agentEmail).get();
    var hotelData = await FirebaseFirestore.instance.collection('users').doc(_selectedHotelEmail).get();
    var cabData = await FirebaseFirestore.instance.collection('users').doc(_selectedCabEmail).get();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Create Unified Booking"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(selectedRange == null 
                    ? "Select Dates" 
                    : "${selectedRange!.start.toLocal().toString().split(' ')[0]} to ${selectedRange!.end.toLocal().toString().split(' ')[0]}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setDialogState(() => selectedRange = picked);
                  },
                ),
                Text("Hotel: ${hotelData.data()?['businessName'] ?? _selectedHotelEmail}", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextField(controller: roomTypeCtrl, decoration: const InputDecoration(labelText: "Room Type & Rooms Count")),
                const Divider(),
                Text("Cab: ${cabData.data()?['businessName'] ?? _selectedCabEmail}", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextField(controller: carTypeCtrl, decoration: const InputDecoration(labelText: "Cab Type & Seats")),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (selectedRange == null || _selectedHotelEmail == null || _selectedCabEmail == null) return;
                FirebaseFirestore.instance.collection('tokens').add({
                  'agentEmail': widget.agentEmail,
                  'agentBusiness': agentData.data()?['businessName'] ?? 'N/A',
                  'agentPhone': agentData.data()?['phone'] ?? 'N/A',
                  'hotelEmail': _selectedHotelEmail,
                  'hotelBusiness': hotelData.data()?['businessName'] ?? 'N/A',
                  'hotelPhone': hotelData.data()?['phone'] ?? 'N/A',
                  'hotelType': roomTypeCtrl.text,
                  'hotelStatus': 'Pending',
                  'cabEmail': _selectedCabEmail,
                  'cabBusiness': cabData.data()?['businessName'] ?? 'N/A',
                  'cabPhone': cabData.data()?['phone'] ?? 'N/A',
                  'cabType': carTypeCtrl.text,
                  'cabStatus': 'Pending',
                  'bookingDate': selectedRange!.start.toLocal().toString().split(' ')[0],
                  'expiryDate': selectedRange!.end.toLocal().toString().split(' ')[0],
                  'overallStatus': 'Pending',
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              }, 
              child: const Text("Generate Token"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users')
              .where('role', whereIn: ['Hotelier', 'Cab Driver']).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            var providers = snapshot.data!.docs;
            return ListView.builder(
              itemCount: providers.length,
              itemBuilder: (context, i) {
                var p = providers[i];
                var data = p.data() as Map<String, dynamic>;
                return ListTile(
                  leading: Icon(p['role'] == "Hotelier" ? Icons.hotel : Icons.car_rental),
                  title: Text(data['businessName'] ?? data['name']),
                  subtitle: Text("${p['role']} | Phone: ${data['phone'] ?? 'N/A'}"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (p['role'] == "Hotelier") _selectedHotelEmail = p.id;
                        if (p['role'] == "Cab Driver") _selectedCabEmail = p.id;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Selected ${data['businessName'] ?? p.id}")));
                    },
                    child: const Text("Select"),
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: _showUnifiedForm,
            label: const Text("Create Token"),
            icon: const Icon(Icons.vpn_key),
          ),
        ),
      ],
    );
  }
}