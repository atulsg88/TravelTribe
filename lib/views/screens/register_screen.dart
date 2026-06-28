import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/register_viewmodel.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showMessage(String? message) {
    if (message != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Consumer<RegisterViewModel>(
        builder: (context, vm, _) {
          // Listen for navigation trigger
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (vm.registeredUser != null) {
              var user = vm.registeredUser!;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MainDashboard(
                    userRole: user.role!,
                    userEmail: user.email,
                  ),
                ),
              );
            }
            if (vm.errorMessage != null) {
              _showMessage(vm.errorMessage);
              vm.clearMessages();
            }
            if (vm.successMessage != null) {
              _showMessage(vm.successMessage);
              vm.clearMessages();
            }
          });

          return Scaffold(
            appBar: AppBar(title: const Text("Register")),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  controller: _nameController,
                  onChanged: vm.setName,
                  decoration: const InputDecoration(labelText: "Full Name"),
                ),
                TextField(
                  controller: _businessNameController,
                  onChanged: vm.setBusinessName,
                  decoration: const InputDecoration(labelText: "Business Name"),
                ),
                TextField(
                  controller: _emailController,
                  onChanged: vm.setEmail,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: _phoneController,
                  onChanged: vm.setPhone,
                  decoration: const InputDecoration(labelText: "Mobile Number"),
                  keyboardType: TextInputType.phone,
                ),
                DropdownButtonFormField<String>(
                  items: [
                    "Travel Agent",
                    "Hotelier",
                    "Cab Driver",
                  ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => vm.setRole(v),
                  decoration: const InputDecoration(labelText: "Role"),
                ),
                if (vm.isOtpSent)
                  TextField(
                    controller: _otpController,
                    decoration: const InputDecoration(labelText: "OTP"),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: vm.isLoading
                      ? null
                      : (vm.isOtpSent
                          ? () => vm.verifyAndRegister(_otpController.text)
                          : () => vm.sendOtp()),
                  child: vm.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(vm.isOtpSent ? "Register" : "Verify Email"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
