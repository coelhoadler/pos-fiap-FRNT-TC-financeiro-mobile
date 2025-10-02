import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_fiap_fin_mobile/components/screens/dashboard/charts/pie/pie_chart.dart';
import 'package:pos_fiap_fin_mobile/components/screens/dashboard/new_transfer/new_transfer.dart';
import 'package:pos_fiap_fin_mobile/components/ui/firebase_logout_util.dart';
import 'package:pos_fiap_fin_mobile/components/ui/header/avatar-header.dart';
import 'package:pos_fiap_fin_mobile/components/ui/header/header.dart';
import 'package:pos_fiap_fin_mobile/utils/routes.dart';

import '../components/screens/dashboard/balance/balance.dart';
import '../components/screens/dashboard/extract/extract.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int extractLimit = 5;

  bool hasTransactions = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> transactionsData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_auth.currentUser == null) {
        Navigator.pushReplacementNamed(context, Routes.login);
        return;
      }
    });

    _getAllTransactions();
  }

  void _getAllTransactions() {
    if (_auth.currentUser == null) return;

    _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('transacoes')
        .snapshots()
        .listen((snapshot) {
          setState(() {
            hasTransactions = snapshot.docs.isNotEmpty;
            transactionsData = snapshot.docs;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        context: context,
        displayName: _auth.currentUser?.displayName ?? 'Usuário Desconhecido',
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF004D61)),
              child: AvatarHeader(),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Transferências'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, Routes.transfers);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
                try {
                  FirebaseLogoutUtil.logout(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Erro ao sair: $e')));
                  }
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Balance(),
            if (hasTransactions)
              TransactionsPieChart(transactionsData: transactionsData),
            NewTransferScreen(),
            Extract(
              titleComponent: 'Últimas transferências',
              limit: extractLimit,
            ),
            if (transactionsData.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.transfers);
                },
                child: Text('Listar todas as transferências'),
              ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
