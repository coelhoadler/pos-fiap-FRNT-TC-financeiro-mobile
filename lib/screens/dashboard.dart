import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_fiap_fin_mobile/utils/routes.dart';

import '../components/screens/dashboard/balance/balance.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_auth.currentUser == null) {
        Navigator.pushReplacementNamed(context, Routes.login);
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard de transferências',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text(
            'Dashboard de transferências | ${_auth.currentUser?.email}',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _auth.signOut();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, Routes.login);
              },
            ),
          ],
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Balance(
                nameUser: 'Joana',
                amount: 100.0,
                dateTime: DateTime.now(),
              ),
              Text('Nova Transação'),
            ],
          ),
        ),
      ),
    );
  }
}
