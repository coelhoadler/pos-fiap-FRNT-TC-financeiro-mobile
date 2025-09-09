import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_fiap_fin_mobile/utils/routes.dart';

class FirebaseLogoutUtil {
  static Future<void> logout(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      Navigator.of(context).pop();
      await auth.signOut();
      Navigator.pushReplacementNamed(context, Routes.login);
    } catch (e) {
      print('Erro ao fazer logout: $e');
    }
  }
}
