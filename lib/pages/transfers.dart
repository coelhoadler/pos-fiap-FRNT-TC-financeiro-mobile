import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TransfersPage extends StatefulWidget {
  const TransfersPage({super.key});

  @override
  State<TransfersPage> createState() => _TransfersPageState();
}

class _TransfersPageState extends State<TransfersPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Página de transferências',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        body: Center(
          child: IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.upload),
            tooltip: 'Upload Image',
          ),
        ),
      ),
    );
  }

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _uploadImageToFirebase(pickedFile.path);
    }
  }

  void _uploadImageToFirebase(String filePath) async {
    try {
      File file = File(filePath);
      String fileName = file.path.split('/').last;

      await FirebaseStorage.instance.ref('uploads/$fileName').putFile(file);
      print('>>> upload realizado com sucesso');
    } catch (e) {
      print('>>> Erro ao realizar upload: $e');
    }
  }
}
