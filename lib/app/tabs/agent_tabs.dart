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
  String _sortFilter = 'All'; // 'All', 'Hotelier', 'Cab Driver'

  void _showUnifiedForm() async {
    if (_selectedHotelEmail == null || _selectedCabEmail == null) {
      String missing = '';
      if (_selectedHotelEmail == null && _selectedCabEmail == null) {
        missing = 'a Hotel and a Cab';
      } else if (_selectedHotelEmail == null) {
        missing = 'a Hotel';
      } else {
        missing = 'a Cab';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select $missing before creating a token.')),
      );
      return;
    }

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
        Column(
          children: [
            // Sort/Filter row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.sort, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  const Text("Sort by:", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  _buildSortChip("All", Icons.list),
                  const SizedBox(width: 6),
                  _buildSortChip("Hotelier", Icons.hotel, label: "Hotels"),
                  const SizedBox(width: 6),
                  _buildSortChip("Cab Driver", Icons.car_rental, label: "Cabs"),
                ],
              ),
            ),
            const Divider(height: 1),
            // Provider list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _sortFilter == 'All'
                    ? FirebaseFirestore.instance.collection('users')
                        .where('role', whereIn: ['Hotelier', 'Cab Driver']).snapshots()
                    : FirebaseFirestore.instance.collection('users')
                        .where('role', isEqualTo: _sortFilter).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  var providers = snapshot.data!.docs;
                  if (providers.isEmpty) {
                    return Center(child: Text("No ${_sortFilter == 'All' ? 'providers' : _sortFilter == 'Hotelier' ? 'hotels' : 'cabs'} found.", style: const TextStyle(color: Colors.white54)));
                  }
                  return ListView.builder(
                    itemCount: providers.length,
                    itemBuilder: (context, i) {
                      var p = providers[i];
                      var data = p.data() as Map<String, dynamic>;
                      bool isHotel = p['role'] == "Hotelier";
                      bool isSelected = isHotel
                          ? _selectedHotelEmail == p.id
                          : _selectedCabEmail == p.id;
                      // Check if another provider of same type is already selected
                      bool otherSelected = isHotel
                          ? (_selectedHotelEmail != null && _selectedHotelEmail != p.id)
                          : (_selectedCabEmail != null && _selectedCabEmail != p.id);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            isHotel ? Icons.hotel : Icons.car_rental,
                            color: isSelected ? Colors.greenAccent : Colors.white54,
                          ),
                          title: Text(data['businessName'] ?? data['name']),
                          subtitle: Text("${p['role']} | Phone: ${data['phone'] ?? 'N/A'}"),
                          trailing: isSelected
                              ? ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      if (isHotel) {
                                        _selectedHotelEmail = null;
                                      } else {
                                        _selectedCabEmail = null;
                                      }
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Deselected ${data['businessName'] ?? p.id}")),
                                    );
                                  },
                                  icon: const Icon(Icons.check_circle, size: 18),
                                  label: const Text("Selected"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade700,
                                    foregroundColor: Colors.white,
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: otherSelected
                                      ? null // Disable if another of the same type is already selected
                                      : () {
                                          setState(() {
                                            if (isHotel) {
                                              _selectedHotelEmail = p.id;
                                            } else {
                                              _selectedCabEmail = p.id;
                                            }
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Selected ${data['businessName'] ?? p.id}")),
                                          );
                                        },
                                  child: const Text("Select"),
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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

  Widget _buildSortChip(String filter, IconData icon, {String? label}) {
    bool active = _sortFilter == filter;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: active ? Colors.white : Colors.white54),
      label: Text(label ?? filter),
      selected: active,
      selectedColor: Colors.blueGrey.shade700,
      backgroundColor: const Color(0xFF2A2A3C),
      labelStyle: TextStyle(
        color: active ? Colors.white : Colors.white54,
        fontWeight: active ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _sortFilter = filter),
      side: BorderSide(color: active ? Colors.blueGrey : Colors.transparent),
    );
  }
}