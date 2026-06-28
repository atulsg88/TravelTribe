import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;

  DashboardViewModel({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  int _currentIndex = 0;
  UserModel? _userProfile;
  bool _isLoadingProfile = false;

  // Token status counts
  int _approvedCount = 0;
  int _rejectedCount = 0;
  int _pendingCount = 0;
  bool _isLoadingCounts = false;

  // ─── Getters ───
  int get currentIndex => _currentIndex;
  UserModel? get userProfile => _userProfile;
  bool get isLoadingProfile => _isLoadingProfile;
  int get approvedCount => _approvedCount;
  int get rejectedCount => _rejectedCount;
  int get pendingCount => _pendingCount;
  int get totalCount => _approvedCount + _rejectedCount + _pendingCount;
  bool get isLoadingCounts => _isLoadingCounts;

  // ─── Actions ───

  void setTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> loadProfile(String email) async {
    _isLoadingProfile = true;
    notifyListeners();

    _userProfile = await _firestoreService.getUser(email);
    _isLoadingProfile = false;
    notifyListeners();
  }

  /// Loads token status counts for the user based on their role.
  Future<void> loadTokenCounts(String email, String role) async {
    _isLoadingCounts = true;
    notifyListeners();

    String queryField;
    if (role == 'Travel Agent') {
      queryField = 'agentEmail';
    } else if (role == 'Hotelier') {
      queryField = 'hotelEmail';
    } else {
      queryField = 'cabEmail';
    }

    // Get all tokens for this user
    var tokens = await _firestoreService.getTokensOnce(queryField, email);

    int approved = 0;
    int rejected = 0;
    int pending = 0;

    for (var token in tokens) {
      // For providers, count their specific status; for agents, count overallStatus
      String status;
      if (role == 'Travel Agent') {
        status = token.overallStatus;
      } else if (role == 'Hotelier') {
        status = token.hotelStatus;
      } else {
        status = token.cabStatus;
      }

      if (status == 'Approved') {
        approved++;
      } else if (status == 'Rejected') {
        rejected++;
      } else {
        pending++;
      }
    }

    _approvedCount = approved;
    _rejectedCount = rejected;
    _pendingCount = pending;
    _isLoadingCounts = false;
    notifyListeners();
  }
}
