import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../core/firebase_options.dart';
import 'public_home_frame.dart';
import 'public_search_frame.dart';
import 'public_profile_frame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TravelTrustPublicWeb());
}

class TravelTrustPublicWeb extends StatelessWidget {
  const TravelTrustPublicWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Trust Public',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.grey[800],
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const PublicHomeFrame(),
        '/search': (context) => const PublicSearchFrame(),
        '/profile': (context) => const PublicProfileFrame(),
      },
    );
  }
}