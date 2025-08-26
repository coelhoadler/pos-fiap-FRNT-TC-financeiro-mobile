import 'package:flutter/material.dart';
import 'package:pos_fiap_fin_mobile/utils/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  void _goToRegisterRoute() {
    Navigator.pushNamed(context, Routes.register);
  }

  void _login() {
    // Implement login functionality
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
            SizedBox(height: 20),
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
