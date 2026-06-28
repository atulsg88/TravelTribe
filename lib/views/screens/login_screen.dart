import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_viewmodel.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, vm, _) {
          // Listen for navigation trigger
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (vm.loggedInUser != null) {
              var user = vm.loggedInUser!;
              vm.reset();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainDashboard(
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
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.travel_explore,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Travel Trust",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _emailController,
                      enabled: !vm.isOtpSent,
                      onChanged: vm.setEmail,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (vm.isOtpSent) ...[
                      const SizedBox(height: 15),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "OTP",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: vm.isLoading
                            ? null
                            : (vm.isOtpSent
                                ? () => vm.login(_otpController.text)
                                : () => vm.checkAndSendOtp()),
                        child: vm.isLoading
                            ? const CircularProgressIndicator()
                            : Text(vm.isOtpSent ? "LOGIN" : "SEND OTP"),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text("Register Now"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
