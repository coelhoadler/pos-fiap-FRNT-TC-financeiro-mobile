import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pos_fiap_fin_mobile/components/ui/header/header.dart';
import 'package:pos_fiap_fin_mobile/components/ui/toast_util.dart';

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({
    super.key,
    this.transactionId = '',
    this.imagePathUrl = '',
  });

  final String imagePathUrl;
  final String transactionId;

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _getImageUrl(String path) async {
    return await FirebaseStorage.instance.ref(path).getDownloadURL();
  }

  Future<void> _confirmarExcluirTransacao(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir imagem'),
        content: Text('Tem certeza que deseja excluir esta imagem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Excluir'),
          ),
        ],
      ),
    );

    if (ok == true) {
      _clearUploadedImage();
    }
  }

  Future<void> _clearUploadedImage() async {
    String? id = _auth.currentUser?.uid;
    await _firestore
        .collection('users')
        .doc(id)
        .collection('transacoes')
        .doc(widget.transactionId)
        .update({'imagePathUrl': null});

    await _storage.ref(widget.imagePathUrl).delete();

    if (mounted) {
      ToastUtil.showToast(context, 'Imagem deletada com sucesso.');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        context: context,
        displayName: _auth.currentUser?.displayName ?? 'Usuário Desconhecido',
        showMenuIcon: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<String>(
              future: _getImageUrl(widget.imagePathUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar imagem.');
                } else if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                } else {
                  return Text('Nenhuma imagem encontrada.');
                }
              },
            ),
            ElevatedButton.icon(
              onPressed: () async {
                _confirmarExcluirTransacao(widget.transactionId);
              },
              icon: Icon(Icons.delete),
              label: Text('Excluir Imagem'),
            ),
          ],
        ),
      ),
    );
  }
}
