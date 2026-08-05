import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Кафе Апрель',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _loginError;
  String? _passwordError;

  void _authorize() {
    print('Кнопка авторизации нажата');
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
      print('Есть авторизация!');
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
                      onPressed: _authorize,
                      child: const Text('Авторизоваться', style: TextStyle(fontSize: 16),)
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
