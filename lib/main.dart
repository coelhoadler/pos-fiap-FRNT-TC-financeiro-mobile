import 'package:flutter/material.dart';
import 'package:project/pages/dashboard.dart';
import 'package:project/pages/transfers.dart';
import 'package:project/pages/login.dart';
import 'package:project/utils/routes.dart';

void main() {
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
      initialRoute: Routes.login,
      routes: {
        Routes.login: (context) => const LoginPage(title: 'Login Page'),
        Routes.dashboard: (context) => const DashboardPage(),
        Routes.transfers: (context) => const TransfersPage(),
      },
    );
  }
}
