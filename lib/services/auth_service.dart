import 'package:email_otp/email_otp.dart';

/// Centralizes all OTP/SMTP logic.
class AuthService {
  /// Configures SMTP and sends an OTP to the given email.
  Future<bool> sendOtp(String email) async {
    EmailOTP.config(
      appName: "Travel Trust",
      otpLength: 4,
      otpType: OTPType.numeric,
    );
    EmailOTP.setSMTP(
      host: "smtp.gmail.com",
      emailPort: EmailPort.port587,
      secureType: SecureType.tls,
      username: "atulgirigosavi333@gmail.com",
      password: "pcpz nqvq ictj xzaz",
    );
    return await EmailOTP.sendOTP(email: email);
  }

  /// Verifies the OTP entered by the user.
  bool verifyOtp(String otp) {
    return EmailOTP.verifyOTP(otp: otp);
  }
}
