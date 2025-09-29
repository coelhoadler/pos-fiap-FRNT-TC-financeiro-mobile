import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_fiap_fin_mobile/components/screens/dashboard/charts/pie/pie_chart.dart';
import 'package:pos_fiap_fin_mobile/components/screens/dashboard/new_transfer/new_transfer.dart';
import 'package:pos_fiap_fin_mobile/components/ui/firebase_logout_util.dart';
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

  String? _photoUrl;
  bool _uploadingAvatar = false;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickAndUploadAvatar() async {
    if (_auth.currentUser == null) return;

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _uploadingAvatar = true);

      final file = File(picked.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(_auth.currentUser!.uid)
          .child('avatar.jpg');

      await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      final downloadUrl = await ref.getDownloadURL();

      await _auth.currentUser!.updatePhotoURL(downloadUrl);
      await _auth.currentUser!.reload();
      setState(() {
        _photoUrl = downloadUrl;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar avatar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
      }
    }
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white24,
                          backgroundImage:
                              (_photoUrl != null && _photoUrl!.isNotEmpty)
                              ? NetworkImage(_photoUrl!)
                              : null,
                          child: (_photoUrl == null || _photoUrl!.isEmpty)
                              ? Text(
                                  (_auth.currentUser?.displayName ?? 'U')
                                      .trim()
                                      .split(' ')
                                      .where((p) => p.isNotEmpty)
                                      .take(2)
                                      .map((p) => p[0].toUpperCase())
                                      .join(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        if (_uploadingAvatar)
                          const SizedBox(
                            height: 72,
                            width: 72,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          ),
                        if (!_uploadingAvatar)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _auth.currentUser?.displayName ?? 'Usuário',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _auth.currentUser?.email ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
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
                FirebaseLogoutUtil.logout(context);
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
