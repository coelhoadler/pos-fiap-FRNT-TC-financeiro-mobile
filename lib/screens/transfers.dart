import 'package:flutter/material.dart';
import 'package:pos_fiap_fin_mobile/components/ui/firebase_logout_util.dart';
import '../components/screens/dashboard/extract/extract.dart';
import '../components/ui/header/header.dart' show Header;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pos_fiap_fin_mobile/utils/routes.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
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
    return Scaffold(
      appBar: Header(
        context: context,
        displayName: _auth.currentUser?.displayName ?? 'Usuário Desconhecido',
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Extract(uploadImage: true, titleComponent: 'Transferências'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF004D61)),
              child: Text(
                _auth.currentUser?.displayName ?? 'Usuário',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Início'),
              onTap: () {
                Navigator.pushNamed(context, Routes.dashboard);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sair'),
              onTap: () async {
                FirebaseLogoutUtil.logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
