import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_fiap_fin_mobile/components/ui/inputs/password_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setErrorMessage('');
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar uma conta'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Qual o seu nome? ',
                hintText: 'Digite seu nome',
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail *'),
            ),
            PasswordInput(controller: _passwordController),
            const SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: Text('Criar minha conta'),
                  ),
            SizedBox(height: 20),
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

  void _register() async {
    setErrorMessage('');
    setState(() {
      _isLoading = true;
    });

    try {
      final textEmail = _emailController.text;
      final textPassword = _passwordController.text;

      await _auth.createUserWithEmailAndPassword(
        email: textEmail,
        password: textPassword,
      );

      User? user = FirebaseAuth.instance.currentUser;
      await user?.updateDisplayName(
        _nameController.text ?? 'Usuário desconhecido',
      );

      await _auth.currentUser?.sendEmailVerification();

      Navigator.pop(context, textEmail);
    } on FirebaseAuthException catch (e) {
      setErrorMessage(e.message ?? 'Erro desconhecido');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void setErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
  }
}
