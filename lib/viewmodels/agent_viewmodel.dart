import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class AgentViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;

  AgentViewModel({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  String? _selectedHotelEmail;
  String? _selectedCabEmail;
  String _sortFilter = 'All';

  // ─── Getters ───
  String? get selectedHotelEmail => _selectedHotelEmail;
  String? get selectedCabEmail => _selectedCabEmail;
  String get sortFilter => _sortFilter;

  /// Stream of providers based on current sort filter.
  Stream<List<UserModel>> get providersStream =>
      _firestoreService.getProvidersStream(_sortFilter);

  // ─── Actions ───

  void setSortFilter(String filter) {
    _sortFilter = filter;
    notifyListeners();
  }

  void selectProvider(String id, String role) {
    if (role == 'Hotelier') {
      _selectedHotelEmail = id;
    } else if (role == 'Cab Driver') {
      _selectedCabEmail = id;
    }
    notifyListeners();
  }

  void deselectProvider(String role) {
    if (role == 'Hotelier') {
      _selectedHotelEmail = null;
    } else if (role == 'Cab Driver') {
      _selectedCabEmail = null;
    }
    notifyListeners();
  }

  /// Returns true if the given provider is currently selected.
  bool isSelected(String id, String role) {
    if (role == 'Hotelier') return _selectedHotelEmail == id;
    return _selectedCabEmail == id;
  }

  /// Returns true if another provider of the same role is already selected.
  bool isOtherSelected(String id, String role) {
    if (role == 'Hotelier') {
      return _selectedHotelEmail != null && _selectedHotelEmail != id;
    }
    return _selectedCabEmail != null && _selectedCabEmail != id;
  }

  /// Validates selection. Returns a message string if something is missing, or null if valid.
  String? validateSelection() {
    if (_selectedHotelEmail == null && _selectedCabEmail == null) {
      return 'Please select a Hotel and a Cab before creating a token.';
    } else if (_selectedHotelEmail == null) {
      return 'Please select a Hotel before creating a token.';
    } else if (_selectedCabEmail == null) {
      return 'Please select a Cab before creating a token.';
    }
    return null;
  }

  /// Creates a token in Firestore.
  Future<void> createToken({
    required String agentEmail,
    required String roomType,
    required String cabType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    var agentUser = await _firestoreService.getUser(agentEmail);
    var hotelUser = await _firestoreService.getUser(_selectedHotelEmail!);
    var cabUser = await _firestoreService.getUser(_selectedCabEmail!);

    await _firestoreService.createToken({
      'agentEmail': agentEmail,
      'agentBusiness': agentUser?.businessName ?? 'N/A',
      'agentPhone': agentUser?.phone ?? 'N/A',
      'hotelEmail': _selectedHotelEmail,
      'hotelBusiness': hotelUser?.businessName ?? 'N/A',
      'hotelPhone': hotelUser?.phone ?? 'N/A',
      'hotelType': roomType,
      'hotelStatus': 'Pending',
      'cabEmail': _selectedCabEmail,
      'cabBusiness': cabUser?.businessName ?? 'N/A',
      'cabPhone': cabUser?.phone ?? 'N/A',
      'cabType': cabType,
      'cabStatus': 'Pending',
      'bookingDate': startDate.toLocal().toString().split(' ')[0],
      'expiryDate': endDate.toLocal().toString().split(' ')[0],
      'overallStatus': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
