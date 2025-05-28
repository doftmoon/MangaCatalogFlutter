import 'package:flutter/material.dart';
import 'package:manga_catalog_app/providers/global_state.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: FormSwitcher()),
    );
  }
}

class FormSwitcher extends StatefulWidget {
  const FormSwitcher({super.key});

  @override
  State<FormSwitcher> createState() => _FormSwitcherState();
}

class _FormSwitcherState extends State<FormSwitcher> {
  var selectedIndex = 0; // 0 для Login, 1 для Register

  void toggleForm() {
    setState(() {
      selectedIndex = selectedIndex == 0 ? 1 : 0; // Переключаем индекс
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (selectedIndex == 0)
            LoginForm(onLogin: handleLogin)
          else
            RegisterForm(onRegister: handleRegister),
          SizedBox(height: 32),
          TextButton(
            onPressed: toggleForm,
            child: Text(
              selectedIndex == 0
                  ? 'No account yet? Register'
                  : 'Already have an account? Sign in',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handleLogin(String email, String password) async {
    var result = await signInUser(email, password);
    if (result != null) {
      Provider.of<GlobalAppState>(context, listen: false).setUid(result['uid']);
      Provider.of<GlobalAppState>(
        context,
        listen: false,
      ).setRole(result['role']);
      print('UID: ${result['uid']}, Role: ${result['role']}');
      Navigator.pop(context);
    } else {
      // Обработка ошибки входа
      print('Error during login');
    }
  }

  Future<void> handleRegister(String email, String password) async {
    String? uid = await registerUser(email, password);
    if (uid != null) {
      Provider.of<GlobalAppState>(context, listen: false).setUid(uid);
      Provider.of<GlobalAppState>(
        context,
        listen: false,
      ).setRole('user'); // Устанавливаем базовую роль
      print('UID пользователя: $uid');
      Navigator.pop(context);
      // Перейдите на главный экран или другой экран
    }
  }
}

class RegisterForm extends StatelessWidget {
  RegisterForm({super.key, required this.onRegister});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Future<void> Function(String, String) onRegister;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Register', style: TextStyle(color: Colors.white, fontSize: 24)),
        SizedBox(height: 16),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.grey[800],
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 12),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.grey[800],
          ),
          obscureText: true,
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed:
              () => onRegister(emailController.text, passwordController.text),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.grey[800]),
          ),
          child: Text(
            'Register',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class LoginForm extends StatelessWidget {
  LoginForm({super.key, required this.onLogin});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Future<void> Function(String, String) onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Signing in', style: TextStyle(color: Colors.white, fontSize: 24)),
        SizedBox(height: 16),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.grey[800],
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 12),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.grey[800],
          ),
          obscureText: true,
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed:
              () => onLogin(emailController.text, passwordController.text),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.grey[800]),
          ),
          child: Text(
            'Sign in',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
