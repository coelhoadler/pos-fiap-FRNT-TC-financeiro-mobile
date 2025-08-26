import 'package:flutter/material.dart';
import 'package:pos_fiap_fin_mobile/utils/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void goToRegisterRoute() {
    Navigator.pushNamed(context, Routes.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: goToRegisterRoute,
            child: Text('Cadastre-se'),
          ),
        ],
      ),
    );
  }
}
