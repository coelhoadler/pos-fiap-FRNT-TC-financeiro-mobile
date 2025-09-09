import 'package:flutter/material.dart';
import 'package:pos_fiap_fin_mobile/screens/image_gallery.dart';
import 'package:pos_fiap_fin_mobile/screens/login.dart';
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
    return MaterialApp(
      routes: {Routes.login: (context) => const LoginScreen()},
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      onGenerateRoute: (settings) {
        if (settings.name == Routes.imageGallery) {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          final imagePathUrl = args['imagePathUrl'] as String? ?? '';
          final transactionId = args['transactionId'] as String? ?? '';

          return MaterialPageRoute(
            builder: (context) => ImageGalleryScreen(
              imagePathUrl: imagePathUrl,
              transactionId: transactionId,
            ),
          );
        }
        return null;
      },
      home: Scaffold(
        appBar: Header(
          context: context,
          displayName: _auth.currentUser?.displayName ?? 'Usuário Desconhecido',
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
                  await _auth.signOut();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, Routes.login);
                },
              ),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Extract(uploadImage: true, titleComponent: 'Transferências'),
            ],
          ),
        ),
      ),
    );
  }
}
