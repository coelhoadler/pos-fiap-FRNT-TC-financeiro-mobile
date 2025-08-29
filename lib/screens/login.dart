import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_fiap_fin_mobile/components/ui/inputs/password_input.dart';
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

  void setErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _login() async {
    setErrorMessage('');

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      bool isVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;

      _goToDashboard();
    } on FirebaseAuthException catch (e) {
      setErrorMessage(e.message ?? 'Erro desconhecido');
    }
  }

  @override
  void initState() {
    super.initState();
    setErrorMessage('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'E-mail *'),
              controller: _emailController,
            ),
            PasswordInput(controller: _passwordController),
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
