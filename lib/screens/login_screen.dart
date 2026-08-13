import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _loginError;
  String? _passwordError;

  void _authorize(BuildContext context) {
    String? loginError;
    String? passwordError;

    if (_loginController.text.isEmpty && _passwordController.text.isEmpty) {
      loginError = 'Заполните логин';
      passwordError = 'Заполните пароль';
    } else if (_loginController.text.isEmpty) {
      loginError = 'Заполните логин';
    } else if (_passwordController.text.isEmpty) {
      passwordError = 'Заполните пароль';
    }

    setState(() {
      _loginError = loginError;
      _passwordError = passwordError;
    });

    if (loginError == null && passwordError == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text(
              'Кафе Апрель',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            const Text('Вход для сотрудников', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  TextField(
                    controller: _loginController,
                    onChanged: (value) {
                      if (_loginError != null && value.isNotEmpty) {
                        setState(() {
                          _loginError = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      errorText: _loginError,
                      border: OutlineInputBorder(),
                      labelText: 'Логин',
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    onChanged: (value) {
                      if (_passwordError != null && value.isNotEmpty) {
                        setState(() {
                          _passwordError = null;
                        });
                      }
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      errorText: _passwordError,
                      border: OutlineInputBorder(),
                      labelText: 'Пароль',
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _authorize(context),
                    child: const Text('Авторизоваться', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}