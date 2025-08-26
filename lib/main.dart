import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pos_fiap_fin_mobile/pages/dashboard.dart';
import 'package:pos_fiap_fin_mobile/pages/register.dart';
import 'package:pos_fiap_fin_mobile/pages/transfers.dart';
import 'package:pos_fiap_fin_mobile/pages/login.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      initialRoute: Routes.register,
      routes: {
        Routes.login: (context) => const LoginPage(title: 'Login Page'),
        Routes.dashboard: (context) => const DashboardPage(),
        Routes.transfers: (context) => const TransfersPage(),
        Routes.register: (context) => const RegisterPage(),
      },
    );
  }
}
