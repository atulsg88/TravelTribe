import 'package:flutter/material.dart';
import 'package:email_otp/email_otp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  bool _isOtpSent = false;
  bool _isLoading = false;

  void _msg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _checkAndSendOtp() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      _msg("Please enter your email");
      return;
    }

    setState(() => _isLoading = true);

    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();

      if (!userDoc.exists) {
        setState(() => _isLoading = false);
        _msg("Account not found. Please register first.");
        return;
      }

      // CORRECTED SMTP CONFIGURATION
      EmailOTP.config(appName: "Travel Trust", otpLength: 4, otpType: OTPType.numeric);
      EmailOTP.setSMTP(
        host: "smtp.gmail.com",
        emailPort: EmailPort.port587,
        secureType: SecureType.tls,
        username: "atulgirigosavi333@gmail.com", // Replace with your email
        password: "pcpz nqvq ictj xzaz",    // Replace with your 16-digit App Password
      );

      bool success = await EmailOTP.sendOTP(email: email);
      
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (success) {
          _isOtpSent = true;
          _msg("OTP sent successfully!");
        } else {
          _msg("Failed to send OTP.");
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _msg("Error: ${e.toString()}");
    }
  }

  void _login() async {
    if (_otpController.text.isEmpty) {
      _msg("Please enter the OTP");
      return;
    }

    setState(() => _isLoading = true);

    if (EmailOTP.verifyOTP(otp: _otpController.text.trim())) {
      try {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_emailController.text.trim())
            .get();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainDashboard(
              userRole: userDoc['role'], 
              userEmail: _emailController.text.trim(),
            ),
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        _msg("Login error: ${e.toString()}");
      }
    } else {
      setState(() => _isLoading = false);
      _msg("Invalid OTP.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const Icon(Icons.travel_explore, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 20),
              const Text("Travel Trust", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                enabled: !_isOtpSent,
                decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
              ),
              if (_isOtpSent) ...[
                const SizedBox(height: 15),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "OTP", border: OutlineInputBorder()),
                ),
              ],
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : (_isOtpSent ? _login : _checkAndSendOtp),
                  child: _isLoading ? const CircularProgressIndicator() : Text(_isOtpSent ? "LOGIN" : "SEND OTP"),
                ),
              ),
              TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text("Register Now"))
            ],
          ),
        ),
      ),
    );
  }
}