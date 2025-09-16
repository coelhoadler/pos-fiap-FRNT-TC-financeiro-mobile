import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_fiap_fin_mobile/components/ui/inputs/password_input.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        backgroundColor: Color(0xFF004d61),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
        centerTitle: true,
        title: Text('Criar uma conta'),
        toolbarHeight: 100,
        iconTheme: IconThemeData(color: Colors.white,  size: 25),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('lib/assets/svg/logo-bytebank.svg', height: 50),
            SizedBox(height: 50),
            TextField(
              controller: _nameController,
              style: TextStyle(fontSize: 16, color: Color(0xFF004d61)),
              decoration: const InputDecoration(
                labelText: 'Qual o seu nome? ',
                hintText: 'Digite seu nome',
                labelStyle: TextStyle(
                  color: Color(0xFF004d61),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF004d61)),
                ),
                hintStyle: TextStyle(
                  color: Color(0xFF004d61),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail *',
                labelStyle: TextStyle(
                  color: Color(0xFF004d61),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF004d61)),
                ),
                hintStyle: TextStyle(
                  color: Color(0xFF004d61),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              style: TextStyle(fontSize: 16, color: Color(0xFF004d61)),
            ),
            SizedBox(height: 15),
            PasswordInput(controller: _passwordController),
            const SizedBox(height: 30),
            if (_errorMessage.isNotEmpty)
              Center(
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator(color: Color(0xFF004d61))
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF004d61),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 12,
                      ),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    child: Text('Criar minha conta'),
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
      if (message.isEmpty) {
        _errorMessage = "";
        _isLoading = false;
        return;
      } else if (_emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _nameController.text.isEmpty) {
        _errorMessage = "Preencha todos os campos corretamente.";
        _isLoading = false;
        return;
      } else if (!_emailController.text.contains('@') ||
          !_emailController.text.contains('.')) {
        _errorMessage = "Preencha todos os campos corretamente.";
        _isLoading = false;
        return;
      } else {
        _errorMessage =
            "Erro ao cadastrar, verifique os campos e tente novamente";
        _isLoading = false;
        return;
      }
    });
  }
}
