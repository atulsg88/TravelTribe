import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../viewmodels/agent_viewmodel.dart';

class AgentHome extends StatefulWidget {
  final String agentEmail;
  const AgentHome({super.key, required this.agentEmail});

  @override
  State<AgentHome> createState() => _AgentHomeState();
}

class _AgentHomeState extends State<AgentHome> {
  late AgentViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = AgentViewModel();
  }

  void _showUnifiedForm() async {
    // Validate selection via ViewModel
    String? validationMsg = _vm.validateSelection();
    if (validationMsg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationMsg)),
      );
      return;
    }

    final roomTypeCtrl = TextEditingController();
    final carTypeCtrl = TextEditingController();
    DateTimeRange? selectedRange;

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
                TextField(controller: roomTypeCtrl, decoration: const InputDecoration(labelText: "Room Type & Rooms Count")),
                const Divider(),
                TextField(controller: carTypeCtrl, decoration: const InputDecoration(labelText: "Cab Type & Seats")),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (selectedRange == null) return;
                await _vm.createToken(
                  agentEmail: widget.agentEmail,
                  roomType: roomTypeCtrl.text,
                  cabType: carTypeCtrl.text,
                  startDate: selectedRange!.start,
                  endDate: selectedRange!.end,
                );
                if (context.mounted) Navigator.pop(context);
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
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<AgentViewModel>(
        builder: (context, vm, _) {
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
                        _buildSortChip(vm, "All", Icons.list),
                        const SizedBox(width: 6),
                        _buildSortChip(vm, "Hotelier", Icons.hotel, label: "Hotels"),
                        const SizedBox(width: 6),
                        _buildSortChip(vm, "Cab Driver", Icons.car_rental, label: "Cabs"),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Provider list
                  Expanded(
                    child: StreamBuilder<List<UserModel>>(
                      stream: vm.providersStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        var providers = snapshot.data!;
                        if (providers.isEmpty) {
                          return Center(
                            child: Text(
                              "No ${vm.sortFilter == 'All' ? 'providers' : vm.sortFilter == 'Hotelier' ? 'hotels' : 'cabs'} found.",
                              style: const TextStyle(color: Colors.white54),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: providers.length,
                          itemBuilder: (context, i) {
                            var provider = providers[i];
                            bool isHotel = provider.role == "Hotelier";
                            bool selected = vm.isSelected(provider.email, provider.role!);
                            bool otherSelected = vm.isOtherSelected(provider.email, provider.role!);

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: ListTile(
                                leading: Icon(
                                  isHotel ? Icons.hotel : Icons.car_rental,
                                  color: selected ? Colors.greenAccent : Colors.white54,
                                ),
                                title: Text(provider.businessName ?? provider.name ?? 'N/A'),
                                subtitle: Text("${provider.role} | Phone: ${provider.phone ?? 'N/A'}"),
                                trailing: selected
                                    ? ElevatedButton.icon(
                                        onPressed: () {
                                          vm.deselectProvider(provider.role!);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Deselected ${provider.businessName ?? provider.email}")),
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
                                            ? null
                                            : () {
                                                vm.selectProvider(provider.email, provider.role!);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text("Selected ${provider.businessName ?? provider.email}")),
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
        },
      ),
    );
  }

  Widget _buildSortChip(AgentViewModel vm, String filter, IconData icon, {String? label}) {
    bool active = vm.sortFilter == filter;
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
      onSelected: (_) => vm.setSortFilter(filter),
      side: BorderSide(color: active ? Colors.blueGrey : Colors.transparent),
    );
  }
}
