import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
        content: const Text('Tem certeza que deseja excluir esta imagem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (ok == true) {
      _clearUploadedImage();
    }
  }

  _clearUploadedImage() async {
    String? id = _auth.currentUser?.uid;
    await _firestore
        .collection('users')
        .doc(id)
        .collection('transacoes')
        .doc(widget.transactionId)
        .update({'imagePathUrl': null});
    await _storage.ref(widget.imagePathUrl).delete();

    ToastUtil.showToast(context, 'Imagem deletada com sucesso.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visualizador de imagem anexada')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<String>(
              future: _getImageUrl(widget.imagePathUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Image.network(
                      snapshot.data!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar imagem');
                }
                return CircularProgressIndicator();
              },
            ),
            ElevatedButton(
              onPressed: () async {
                _confirmarExcluirTransacao(widget.transactionId);
              },
              child: Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
