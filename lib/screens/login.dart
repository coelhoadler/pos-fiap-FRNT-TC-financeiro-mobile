import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final FlutterSecureStorage _flutterStorage = FlutterSecureStorage();

  String _errorMessage = '';
  bool _isLoading = false;

  void _goToRegisterRoute() {
    Navigator.pushNamed(context, Routes.register);
  }

  void _goToDashboard() {
    Navigator.pushReplacementNamed(context, Routes.dashboard);
  }

  void setErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  void _login() async {
    setErrorMessage('');
    setState(() {
      _isLoading = true;
    });
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      _saveCredentials(_emailController.text, _passwordController.text);

      _goToDashboard();
    } on FirebaseAuthException catch (e) {
      setErrorMessage(e.message ?? 'Erro desconhecido');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCredentials(String login, String senha) async {
    await _flutterStorage.write(key: 'login', value: login);
    await _flutterStorage.write(key: 'senha', value: senha);
  }

  Future<void> _loadCredentials() async {
    String? email = await _flutterStorage.read(key: 'email');
    String? senha = await _flutterStorage.read(key: 'senha');

    if (email != null) {
      setState(() {
        _emailController.text = email;
      });
    }
    if (senha != null) {
      setState(() {
        _passwordController.text = senha;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setErrorMessage('');

    _loadCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Login Page'),
        automaticallyImplyLeading: false,
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
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: Text('Login')),
            TextButton(
              onPressed: _goToRegisterRoute,
              child: Text('Criar uma conta'),
            ),
            if (_errorMessage.isNotEmpty)
              Center(
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
