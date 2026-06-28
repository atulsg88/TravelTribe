import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
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
  late DashboardViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = DashboardViewModel();
    _vm.loadProfile(widget.userEmail);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          Widget homeTab = widget.userRole == "Travel Agent"
              ? AgentHome(agentEmail: widget.userEmail)
              : ProviderHome(userRole: widget.userRole, providerEmail: widget.userEmail);

          final List<Widget> tabs = [
            homeTab,
            MyTokensList(userEmail: widget.userEmail, role: widget.userRole),
            _buildProfileTab(vm),
          ];

          return Scaffold(
            appBar: AppBar(
              title: Text("${widget.userRole} Dashboard"),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                ),
              ],
            ),
            body: tabs[vm.currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: vm.currentIndex,
              onTap: (index) => vm.setTab(index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.add_task), label: "Requests"),
                BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileTab(DashboardViewModel vm) {
    if (vm.isLoadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.userProfile == null) {
      return const Center(child: Text("Profile not found."));
    }
    var profile = vm.userProfile!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 80, color: Colors.blueGrey),
          Text("Name: ${profile.name ?? 'N/A'}", style: const TextStyle(fontSize: 20)),
          Text("Business: ${profile.businessName ?? 'N/A'}",
              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary)),
          Text("Role: ${widget.userRole}"),
          Text("Email: ${widget.userEmail}"),
          Text("Phone: ${profile.phone ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
