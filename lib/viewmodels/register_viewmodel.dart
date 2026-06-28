import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  RegisterViewModel({AuthService? authService, FirestoreService? firestoreService})
      : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService();

  String _name = '';
  String _businessName = '';
  String _email = '';
  String _phone = '';
  String? _selectedRole;
  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  UserModel? _registeredUser;

  // ─── Getters ───
  String get name => _name;
  String get businessName => _businessName;
  String get email => _email;
  String get phone => _phone;
  String? get selectedRole => _selectedRole;
  bool get isOtpSent => _isOtpSent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  UserModel? get registeredUser => _registeredUser;

  // ─── Setters ───
  void setName(String v) => _name = v;
  void setBusinessName(String v) => _businessName = v;
  void setEmail(String v) => _email = v.trim();
  void setPhone(String v) => _phone = v.trim();
  void setRole(String? v) => _selectedRole = v;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  // ─── Actions ───

  Future<void> sendOtp() async {
    if (_email.isEmpty || _selectedRole == null || _phone.isEmpty || _businessName.isEmpty) {
      _errorMessage = "Please fill all fields including Business Name";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    bool res = await _authService.sendOtp(_email);
    _isLoading = false;
    _isOtpSent = res;
    if (res) {
      _successMessage = "OTP Sent";
    } else {
      _errorMessage = "Failed to send OTP.";
    }
    notifyListeners();
  }

  Future<void> verifyAndRegister(String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (_authService.verifyOtp(otp)) {
      var user = UserModel(
        name: _name,
        businessName: _businessName.trim(),
        role: _selectedRole,
        email: _email,
        phone: _phone,
      );
      await _firestoreService.createUser(user);
      _isLoading = false;
      _registeredUser = user;
      notifyListeners();
    } else {
      _isLoading = false;
      _errorMessage = "Invalid OTP";
      notifyListeners();
    }
  }
}
