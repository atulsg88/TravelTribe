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

  // ─── Getters ───
  int get currentIndex => _currentIndex;
  UserModel? get userProfile => _userProfile;
  bool get isLoadingProfile => _isLoadingProfile;

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
}
