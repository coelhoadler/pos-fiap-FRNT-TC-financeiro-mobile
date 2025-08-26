import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pos_fiap_fin_mobile/screens/dashboard.dart';
import 'package:pos_fiap_fin_mobile/screens/register.dart';
import 'package:pos_fiap_fin_mobile/screens/transfers.dart';
import 'package:pos_fiap_fin_mobile/screens/login.dart';
import 'package:pos_fiap_fin_mobile/utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      initialRoute: Routes.login,
      routes: {
        Routes.login: (context) => const LoginScreen(),
        Routes.dashboard: (context) => const DashboardScreen(),
        Routes.transfers: (context) => const TransfersScreen(),
        Routes.register: (context) => const RegisterScreen(),
      },
    );
  }
}
