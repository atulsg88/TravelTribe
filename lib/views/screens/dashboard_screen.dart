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
    _vm.loadTokenCounts(widget.userEmail, widget.userRole);
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
              onTap: (index) {
                vm.setTab(index);
                // Refresh counts when going to profile tab
                if (index == 2) {
                  vm.loadTokenCounts(widget.userEmail, widget.userRole);
                }
              },
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.person, size: 80, color: Colors.blueGrey),
          const SizedBox(height: 12),
          Text(profile.name ?? 'N/A', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(profile.businessName ?? 'N/A',
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 4),
          Text(widget.userRole, style: const TextStyle(color: Colors.white54)),
          Text(widget.userEmail, style: const TextStyle(color: Colors.white54)),
          Text(profile.phone ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          // ─── Token Status Counts ───
          const Text("Token Statistics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (vm.isLoadingCounts)
            const CircularProgressIndicator()
          else
            Row(
              children: [
                Expanded(child: _buildCountCard("Approved", vm.approvedCount, Colors.green)),
                const SizedBox(width: 10),
                Expanded(child: _buildCountCard("Pending", vm.pendingCount, Colors.orange)),
                const SizedBox(width: 10),
                Expanded(child: _buildCountCard("Rejected", vm.rejectedCount, Colors.red)),
              ],
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A3C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.token, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 8),
                Text("Total Tokens: ${vm.totalCount}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 13, color: color.withAlpha(200))),
        ],
      ),
    );
  }
}
