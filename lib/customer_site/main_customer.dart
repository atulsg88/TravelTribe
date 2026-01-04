import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../core/firebase_options.dart';
import 'customer_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure this line matches exactly:
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Change this line to be more flexible
final String tokenId = Uri.base.queryParameters['id'] ?? Uri.base.fragment.split('id=').last;
  runApp(MaterialApp(home: CustomerVerificationPage(tokenId: tokenId)));
}