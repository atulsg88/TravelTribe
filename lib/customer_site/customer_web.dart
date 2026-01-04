import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerVerificationPage extends StatefulWidget {
  final String tokenId; 
  const CustomerVerificationPage({super.key, required this.tokenId});

  @override
  State<CustomerVerificationPage> createState() => _CustomerVerificationPageState();
}

class _CustomerVerificationPageState extends State<CustomerVerificationPage> {
  final _emailController = TextEditingController();
  bool _isVerified = false;
  bool _isLoading = false;
  bool _isProcessingAction = false;

  void _verifyAndEnter() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your email")));
      return;
    }
    setState(() => _isLoading = true);
    var doc = await FirebaseFirestore.instance.collection('tokens').doc(widget.tokenId).get();
    setState(() {
      _isLoading = false;
      if (doc.exists) {
        _isVerified = true; 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid or Expired Link")));
      }
    });
  }

  void _updateTokenStatus(String status) async {
    if (_isProcessingAction) return; // Prevent double execution
    setState(() => _isProcessingAction = true);
    try {
      await FirebaseFirestore.instance.collection('tokens').doc(widget.tokenId).update({
        'overallStatus': status, 
      });
    } finally {
      if (mounted) setState(() => _isProcessingAction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVerified) return _buildLoginUI();
    
    return Scaffold(
      appBar: AppBar(title: const Text("Your Booking Confirmation")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('tokens').doc(widget.tokenId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var data = snapshot.data!.data() as Map<String, dynamic>;
          String currentStatus = data['overallStatus'] ?? 'Pending';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailTile("Travel Agent", "${data['agentBusiness']}\nPhone: ${data['agentPhone'] ?? 'N/A'}", Icons.person),
                const Divider(),
                _detailTile("Hotelier", "${data['hotelBusiness']}\nPhone: ${data['hotelPhone'] ?? 'N/A'}\nRequirement: ${data['hotelType']}", Icons.hotel),
                _detailTile("Cab Driver", "${data['cabBusiness']}\nPhone: ${data['cabPhone'] ?? 'N/A'}\nRequirement: ${data['cabType']}", Icons.directions_car),
                _detailTile("Dates", "${data['bookingDate']} to ${data['expiryDate']}", Icons.calendar_month),
                const SizedBox(height: 30),
                if (currentStatus == 'Approved') 
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          // Disable button if an action is already processing
                          onPressed: _isProcessingAction ? null : () => _updateTokenStatus("Accepted by Customer"), 
                          child: _isProcessingAction 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text("ACCEPT BOOKING"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          // Disable button if an action is already processing
                          onPressed: _isProcessingAction ? null : () => _updateTokenStatus("Rejected by Customer"), 
                          child: const Text("REJECT"),
                        ),
                      ),
                    ],
                  )
                else
                  Center(child: Text("Booking Status: $currentStatus", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginUI() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Verify Your Email", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(width: 300, child: TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email Address", border: OutlineInputBorder()))),
            const SizedBox(height: 20),
            _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _verifyAndEnter, child: const Text("VIEW DETAILS")),
          ],
        ),
      ),
    );
  }

  Widget _detailTile(String title, String sub, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub),
    );
  }
}