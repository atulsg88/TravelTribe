import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/token_model.dart';
import '../../viewmodels/provider_viewmodel.dart';

class ProviderHome extends StatelessWidget {
  final String userRole;
  final String providerEmail;
  const ProviderHome({super.key, required this.userRole, required this.providerEmail});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProviderViewModel(),
      child: Consumer<ProviderViewModel>(
        builder: (context, vm, _) {
          return StreamBuilder<List<TokenModel>>(
            stream: vm.getTokensStream(userRole, providerEmail),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var tokens = snapshot.data!;
              return ListView.builder(
                itemCount: tokens.length,
                itemBuilder: (context, i) {
                  var token = tokens[i];
                  String status = userRole == 'Hotelier' ? token.hotelStatus : token.cabStatus;

                  return Card(
                    child: ListTile(
                      title: Text("Request from: ${token.agentBusiness ?? token.agentEmail}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Agent Phone: ${token.agentPhone ?? 'N/A'}",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(userRole == "Hotelier"
                              ? "Hotel Requirement: ${token.hotelType}"
                              : "Cab Requirement: ${token.cabType}"),
                        ],
                      ),
                      trailing: status == 'Pending'
                          ? Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () => vm.approveToken(token.id, userRole),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => vm.rejectToken(token.id, userRole),
                              ),
                            ])
                          : Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
