import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({super.key, this.imagePathUrl = ''});
  final String imagePathUrl;

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  Future<String> _getImageUrl(String path) async {
    return await FirebaseStorage.instance.ref(path).getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galeria de Imagens')),
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
                    padding: const EdgeInsets.all(16.0),
                    child: Image.network(snapshot.data!),
                  );
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar imagem');
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
