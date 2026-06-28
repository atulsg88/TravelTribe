import 'package:flutter/foundation.dart';
import '../models/token_model.dart';
import '../services/firestore_service.dart';

class ProviderViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;

  ProviderViewModel({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  /// Returns the Firestore query field for the given role.
  String _queryField(String role) {
    return role == 'Hotelier' ? 'hotelEmail' : 'cabEmail';
  }

  /// Returns the status field for the given role.
  String statusField(String role) {
    return role == 'Hotelier' ? 'hotelStatus' : 'cabStatus';
  }

  /// Returns the other provider's status field.
  String otherStatusField(String role) {
    return role == 'Hotelier' ? 'cabStatus' : 'hotelStatus';
  }

  /// Stream of tokens for this provider, sorted latest first.
  Stream<List<TokenModel>> getTokensStream(String role, String email) {
    return _firestoreService.getTokensStream(_queryField(role), email);
  }

  /// Approves a token for this provider's role.
  Future<void> approveToken(String tokenId, String role) async {
    String field = statusField(role);

    await _firestoreService.updateTokenField(tokenId, field, 'Approved');
    var fresh = await _firestoreService.getToken(tokenId);

    // Check if the other provider has also approved
    String otherStatus = role == 'Hotelier' ? fresh.cabStatus : fresh.hotelStatus;
    if (otherStatus == 'Approved') {
      await _firestoreService.updateTokenField(tokenId, 'overallStatus', 'Approved');
    }
  }

  /// Rejects a token for this provider's role.
  Future<void> rejectToken(String tokenId, String role) async {
    String field = statusField(role);
    await _firestoreService.updateTokenFields(tokenId, {
      field: 'Rejected',
      'overallStatus': 'Rejected',
    });
  }
}
