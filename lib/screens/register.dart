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
  final _formKey = GlobalKey<FormState>();
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
      // Ensure the view resizes when the keyboard appears
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Color(0xFF004d61),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
        centerTitle: true,
        title: Text('Criar uma conta'),
        toolbarHeight: 60,
        iconTheme: IconThemeData(color: Colors.white, size: 25),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // Add bottom padding equal to the keyboard height to keep the
              // focused field visible when the keyboard opens
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.asset(
                          'lib/assets/svg/logo-bytebank.svg',
                          height: 50,
                        ),
                        SizedBox(height: 50),
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF004d61),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe seu nome';
                            }
                            return null;
                          },
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
                        TextFormField(
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o e-mail';
                            }
                            final email = value.trim();
                            final emailRegex = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            );
                            if (!emailRegex.hasMatch(email)) {
                              return 'E-mail inválido';
                            }
                            return null;
                          },
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
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF004d61),
                          ),
                        ),
                        SizedBox(height: 15),
                        PasswordInput(
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe a senha';
                            }
                            if (value.trim().length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
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
                            ? CircularProgressIndicator(
                                color: Color(0xFF004d61),
                              )
                            : ElevatedButton(
                                onPressed: _onSubmit,
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    setErrorMessage('');
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    _register();
  }

  void _register() async {
    setErrorMessage('');
    setState(() {
      _isLoading = true;
    });

    try {
      final textEmail = _emailController.text.trim();
      final textPassword = _passwordController.text.trim();

      await _auth.createUserWithEmailAndPassword(
        email: textEmail,
        password: textPassword,
      );

      User? user = FirebaseAuth.instance.currentUser;
      await user?.updateDisplayName(_nameController.text.trim());

      await _auth.currentUser?.sendEmailVerification();
      if (!mounted) return;
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
