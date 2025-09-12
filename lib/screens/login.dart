import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pos_fiap_fin_mobile/components/ui/inputs/password_input.dart';
import 'package:pos_fiap_fin_mobile/utils/routes.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      if (message.isEmpty) {
        _errorMessage = "";
        _isLoading = false;
        return;
      } else if (_emailController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        _errorMessage = "Preencha todos os campos corretamente.";
        _isLoading = false;
        return;
      } else if (!_emailController.text.contains('@') ||
          !_emailController.text.contains('.')) {
        _errorMessage = "Preencha todos os campos corretamente.";
        _isLoading = false;
        return;
      } else {
        _errorMessage = "Usuário ou senha incorretos.";
        _isLoading = false;
        return;
      }
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
    await _flutterStorage.delete(key: 'login');
    await _flutterStorage.delete(key: 'senha');
    await _flutterStorage.write(key: 'login', value: login);
    await _flutterStorage.write(key: 'senha', value: senha);
  }

  Future<void> _loadCredentials() async {
    // Read the same key used when saving (login)
    String? email = await _flutterStorage.read(key: 'login');
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
        backgroundColor: Color(0xFF004d61),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
        centerTitle: true,
        title: const Text('Login'),
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('lib/assets/svg/logo-bytebank.svg', height: 50),
            SizedBox(height: 50),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'E-mail *',
                labelStyle: TextStyle(
                  color: Color(0xFF004d61),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF004d61)),
                ),
              ),
              style: TextStyle(fontSize: 16, color: Color(0xFF004d61)),
              controller: _emailController,
            ),
            SizedBox(height: 30),
            PasswordInput(controller: _passwordController),
            SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Center(
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isLoading
                    ? CircularProgressIndicator(color: Color(0xFF004d61))
                    : Row(
                        children: [
                          ElevatedButton(
                            onPressed: _login,
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
                              ),
                            ),
                            child: Text('Login'),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _goToRegisterRoute,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF004d61),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              shadowColor: Color(0xFF004d61),
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text('Criar uma conta'),
                          ),
                        ],
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
