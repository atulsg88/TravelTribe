import 'package:flutter/material.dart';
import 'package:email_otp/email_otp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); 
  final _otpController = TextEditingController();
  String? _selectedRole;
  bool _isOtpSent = false;
  bool _isLoading = false; 

  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  void _sendOtp() async {
    if (_emailController.text.isEmpty || _selectedRole == null || 
        _phoneController.text.isEmpty || _businessNameController.text.isEmpty) {
      _msg("Please fill all fields including Business Name");
      return;
    }
    setState(() => _isLoading = true);
    EmailOTP.config(appName: "Travel Trust", otpLength: 4, otpType: OTPType.numeric);
    EmailOTP.setSMTP(
      host: "smtp.gmail.com",
      emailPort: EmailPort.port587,
      secureType: SecureType.tls,
      username: "atulgirigosavi333@gmail.com",
      password: "pcpz nqvq ictj xzaz",
    );
    bool res = await EmailOTP.sendOTP(email: _emailController.text.trim());
    setState(() {
      _isLoading = false;
      _isOtpSent = res;
    });
    if (res) _msg("OTP Sent");
  }

  void _verifyAndRegister() async {
    setState(() => _isLoading = true);
    if (EmailOTP.verifyOTP(otp: _otpController.text)) {
      await FirebaseFirestore.instance.collection('users').doc(_emailController.text).set({
        'name': _nameController.text,
        'businessName': _businessNameController.text.trim(),
        'role': _selectedRole,
        'email': _emailController.text,
        'phone': _phoneController.text.trim(),
      });
      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainDashboard(userRole: _selectedRole!, userEmail: _emailController.text)));
    } else {
      setState(() => _isLoading = false);
      _msg("Invalid OTP");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name")),
          TextField(controller: _businessNameController, decoration: const InputDecoration(labelText: "Business Name")),
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
          TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Mobile Number"), keyboardType: TextInputType.phone),
          DropdownButtonFormField<String>(
            items: ["Travel Agent", "Hotelier", "Cab Driver"].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => _selectedRole = v,
            decoration: const InputDecoration(labelText: "Role"),
          ),
          if (_isOtpSent) TextField(controller: _otpController, decoration: const InputDecoration(labelText: "OTP")),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : (_isOtpSent ? _verifyAndRegister : _sendOtp), 
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_isOtpSent ? "Register" : "Verify Email")
          ),
        ],
      ),
    );
  }
}