import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pos_fiap_fin_mobile/utils/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void _goToRegisterRoute() {
    Navigator.pushNamed(context, Routes.register);
  }

  void _goToDashboard() {
    Navigator.pushReplacementNamed(context, Routes.dashboard);
  }

  void _login() {
    _auth
        .signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        )
        .then((userCredential) {
          _goToDashboard();
        })
        .catchError((error) {
          setState(() {
            _errorMessage = error.message ?? 'Erro desconhecido';
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'E-mail'),
              controller: _emailController,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              controller: _passwordController,
            ),
            SizedBox(height: 50),
            ElevatedButton(onPressed: _login, child: Text('Login')),
            TextButton(
              onPressed: _goToRegisterRoute,
              child: Text('Criar uma conta'),
            ),
            Text(_errorMessage, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
