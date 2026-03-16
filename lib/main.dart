import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
// import 'firebase_options.dart'; // Uncomment this once generated
import 'services/seeder_service.dart'; // Import seeder service for testing

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform, // Uncomment this once generated
  // );

  // Uncomment to seed the database ONCE (then comment out again)
  // await SeederService().seedFirestore();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIU Church Bulletin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF18345E),
        ), // Specific Theme Color branding #18345e
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF18345E),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
