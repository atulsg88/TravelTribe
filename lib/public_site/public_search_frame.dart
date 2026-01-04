import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublicSearchFrame extends StatefulWidget {
  const PublicSearchFrame({super.key});

  @override
  State<PublicSearchFrame> createState() => _PublicSearchFrameState();
}

class _PublicSearchFrameState extends State<PublicSearchFrame> {
  final _searchController = TextEditingController();
  String _query = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Travel Agents")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by Agent Name or Business",
                suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: () => setState(() => _query = _searchController.text)),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users')
                .where('role', isEqualTo: 'Travel Agent').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                var agents = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['businessName'] ?? data['name']).toString().toLowerCase();
                  return name.contains(_query.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: agents.length,
                  itemBuilder: (context, i) {
                    var data = agents[i].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['businessName'] ?? data['name']),
                      subtitle: Text("Verified Agent"),
                      onTap: () => Navigator.pushNamed(context, '/profile', arguments: agents[i].id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}