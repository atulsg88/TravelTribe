import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  LoginViewModel({AuthService? authService, FirestoreService? firestoreService})
      : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService();

  String _email = '';
  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  UserModel? _loggedInUser;

  // ─── Getters ───
  String get email => _email;
  bool get isOtpSent => _isOtpSent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  UserModel? get loggedInUser => _loggedInUser;

  // ─── Setters ───
  void setEmail(String value) {
    _email = value.trim();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  /// Resets state for a fresh login attempt.
  void reset() {
    _email = '';
    _isOtpSent = false;
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    _loggedInUser = null;
    notifyListeners();
  }

  // ─── Actions ───

  Future<void> checkAndSendOtp() async {
    if (_email.isEmpty) {
      _errorMessage = "Please enter your email";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      var user = await _firestoreService.getUser(_email);
      if (user == null) {
        _isLoading = false;
        _errorMessage = "Account not found. Please register first.";
        notifyListeners();
        return;
      }

      bool success = await _authService.sendOtp(_email);
      _isLoading = false;
      if (success) {
        _isOtpSent = true;
        _successMessage = "OTP sent successfully!";
      } else {
        _errorMessage = "Failed to send OTP.";
      }
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Error: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<void> login(String otp) async {
    if (otp.isEmpty) {
      _errorMessage = "Please enter the OTP";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (_authService.verifyOtp(otp.trim())) {
      try {
        var user = await _firestoreService.getUser(_email);
        _isLoading = false;
        if (user != null) {
          _loggedInUser = user;
        } else {
          _errorMessage = "User not found.";
        }
        notifyListeners();
      } catch (e) {
        _isLoading = false;
        _errorMessage = "Login error: ${e.toString()}";
        notifyListeners();
      }
    } else {
      _isLoading = false;
      _errorMessage = "Invalid OTP.";
      notifyListeners();
    }
  }
}
