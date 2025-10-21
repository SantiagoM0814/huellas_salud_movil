import 'package:flutter/material.dart';
import '../../widgets/appbar.dart';
import '../home/home.dart';
import '../user/form.dart';
import './recover_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _registeredUsername;
  String? _registeredPassword;

  @override
  void initState() {
    super.initState();
    _usernameController.text = _registeredUsername ?? '';
    _passwordController.text = _registeredPassword ?? '';
  }

  void _navigateToRegister() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserFormScreen()),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        _registeredUsername = result['username'];
        _registeredPassword = result['password'];
        _usernameController.text = _registeredUsername ?? '';
        _passwordController.text = _registeredPassword ?? '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado con éxito')),
      );
    }
  }

  void _navigateToRecoverPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecoverPasswordScreen()),
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomeScreen(username: username, password: password),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Iniciar Sesión'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Image.asset('assets/img/logos/logo.png', height: 150),
                const SizedBox(height: 5),
                const Text(
                  'Iniciar Sesión',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Documento o correo',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su documento o correo';
                    }

                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    final docRegex = RegExp(r'^[0-9]{6,10}$');

                    if (!emailRegex.hasMatch(value) &&
                        !docRegex.hasMatch(value)) {
                      return 'Ingrese un correo válido o un documento (solo números)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una contraseña';
                    }
                    if (!RegExp(
                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,16}$',
                    ).hasMatch(value)) {
                      return 'Debe tener entre 8 y 16 caracteres,\ncon al menos una mayúscula, una minúscula,\nun número y un carácter especial';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Iniciar Sesión'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _navigateToRegister,
                  child: const Text('¿No tienes cuenta? Regístrate aquí'),
                ),
                const SizedBox(height: 10),
                // NUEVO: Enlace para recuperar contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _navigateToRecoverPassword,
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}