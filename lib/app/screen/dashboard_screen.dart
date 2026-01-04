import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../tabs/agent_tabs.dart';
import '../tabs/provider_tabs.dart';
import '../tabs/token_list.dart';

class MainDashboard extends StatefulWidget {
  final String userRole;
  final String userEmail;
  const MainDashboard({super.key, required this.userRole, required this.userEmail});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget homeTab = widget.userRole == "Travel Agent" 
        ? AgentHome(agentEmail: widget.userEmail) 
        : ProviderHome(userRole: widget.userRole, providerEmail: widget.userEmail);

    final List<Widget> tabs = [
      homeTab,
      MyTokensList(userEmail: widget.userEmail, role: widget.userRole),
      FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.userEmail).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var data = snapshot.data!.data() as Map<String, dynamic>;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 80, color: Colors.blueGrey),
                Text("Name: ${data['name']}", style: const TextStyle(fontSize: 20)),
                Text("Business: ${data['businessName'] ?? 'N/A'}", style: const TextStyle(fontSize: 18, color: Colors.blueGrey)),
                Text("Role: ${widget.userRole}"),
                Text("Email: ${widget.userEmail}"),
                Text("Phone: ${data['phone'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.userRole} Dashboard"),
        automaticallyImplyLeading: false, // Explicitly removes the back button
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), 
            onPressed: () => Navigator.pushReplacementNamed(context, '/')
          ),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_task), label: "Requests"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}