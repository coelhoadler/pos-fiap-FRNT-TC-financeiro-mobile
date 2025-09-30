import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarHeader extends StatefulWidget {
  const AvatarHeader({super.key});

  @override
  State<AvatarHeader> createState() => _AvatarHeaderState();
}

class _AvatarHeaderState extends State<AvatarHeader> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _photoUrl;
  bool _uploadingAvatar = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _photoUrl = _auth.currentUser?.photoURL;
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
    return Column(
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
                backgroundImage: (_photoUrl != null && _photoUrl!.isNotEmpty)
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
    );
  }
}
