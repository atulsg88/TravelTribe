import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../../models/token_model.dart';
import '../../viewmodels/token_list_viewmodel.dart';

class MyTokensList extends StatelessWidget {
  final String userEmail;
  final String role;
  const MyTokensList({super.key, required this.userEmail, required this.role});

  Future<void> _showSendDialog(BuildContext context, TokenListViewModel vm, String tokenId) async {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Send Link to Customer"),
        content: TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: "Customer Email", hintText: "example@mail.com"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String customerEmail = emailCtrl.text.trim();
              if (customerEmail.isEmpty) return;
              await vm.sendEmailLink(tokenId, customerEmail);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Open Mail App"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TokenListViewModel(),
      child: Consumer<TokenListViewModel>(
        builder: (context, vm, _) {
          return StreamBuilder<List<TokenModel>>(
            stream: vm.getTokensStream(role, userEmail),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No tokens found."));
              }

              var tokens = snapshot.data!;
              var heatMapData = vm.buildHeatMapData(tokens);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header row with title and filter chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Contribution Activity",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Row(
                        children: [
                          _buildFilterChip(vm, '6months', '6M'),
                          const SizedBox(width: 6),
                          _buildFilterChip(vm, '1year', '1Y'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _ScrollableHeatMap(
                      startDate: vm.heatmapStartDate,
                      datasets: heatMapData,
                    ),
                  ),
                  const Divider(height: 40),
                  const Text("Token History", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...tokens.map((token) => _buildTokenCard(context, vm, token)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(TokenListViewModel vm, String filter, String label) {
    bool active = vm.heatmapFilter == filter;
    return GestureDetector(
      onTap: () => vm.setHeatmapFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.blueGrey.shade700 : const Color(0xFF2A2A3C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? Colors.blueGrey : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white54,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTokenCard(BuildContext context, TokenListViewModel vm, TokenModel token) {
    bool isSendable = token.isFullyApproved;

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
                Text("Status: ${token.overallStatus}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (role == "Travel Agent" && isSendable && token.overallStatus == 'Approved')
                  ElevatedButton(
                    onPressed: () => _showSendDialog(context, vm, token.id),
                    child: const Text("SEND"),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            if (token.createdAt != null)
              Text(
                "Created: ${vm.formatDate(token.createdAt!)}",
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
            const SizedBox(height: 8),
            // Show status based on role
            if (role == "Travel Agent")
              Text("Hotel: ${token.hotelStatus} | Cab: ${token.cabStatus}")
            else if (role == "Hotelier")
              Text("My Status: ${token.hotelStatus}")
            else
              Text("My Status: ${token.cabStatus}"),
            const Divider(),
            const Text("Contact & Business Info:", style: TextStyle(fontWeight: FontWeight.bold)),
            if (role == "Travel Agent") ...[
              Text("Hotel: ${token.hotelBusiness ?? 'N/A'}\nPhone: ${token.hotelPhone ?? 'N/A'}"),
              Text("Cab: ${token.cabBusiness ?? 'N/A'}\nPhone: ${token.cabPhone ?? 'N/A'}"),
            ] else if (role == "Hotelier") ...[
              Text("Agent: ${token.agentBusiness ?? 'N/A'}"),
              Text("Phone: ${token.agentPhone ?? 'N/A'}"),
            ] else if (role == "Cab Driver") ...[
              Text("Agent: ${token.agentBusiness ?? 'N/A'}"),
              Text("Phone: ${token.agentPhone ?? 'N/A'}"),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScrollableHeatMap extends StatefulWidget {
  final DateTime startDate;
  final Map<DateTime, int> datasets;

  const _ScrollableHeatMap({
    super.key,
    required this.startDate,
    required this.datasets,
  });

  @override
  State<_ScrollableHeatMap> createState() => _ScrollableHeatMapState();
}

class _ScrollableHeatMapState extends State<_ScrollableHeatMap> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _scrollController,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        controller: _scrollController,
        child: HeatMap(
          startDate: widget.startDate,
          endDate: DateTime.now(),
          datasets: widget.datasets,
          colorMode: ColorMode.opacity,
          colorsets: const {1: Colors.green},
          size: 30, // Increased size for clearer month and day text
          scrollable: false,
          showText: true,
          showColorTip: false,
          textColor: Colors.black,
        ),
      ),
    );
  }
}
