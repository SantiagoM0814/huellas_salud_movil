import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/appbar.dart';
import '../../theme/theme_app.dart';
import '../../theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  final String username;
  final String password;

  const SettingsScreen({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // Verificar el tema actual al iniciar
    _checkCurrentTheme();
  }

  void _checkCurrentTheme() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    setState(() {
      _isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    });
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    
    // Cambiar el tema globalmente usando Provider
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.setTheme(value ? ThemeMode.dark : ThemeMode.light);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tema ${value ? 'oscuro' : 'claro'} activado'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Configuración',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apariencia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
           
            // ✅ Selector de tema
            _buildThemeSelector(),
            const SizedBox(height: 20),
           
            const Text(
              'Opciones de Cuenta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
           
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildFeatureCard(context, Icons.email, 'Cambiar Email', 'Actualiza tu dirección de correo electrónico', Colors.blue),
                  const SizedBox(height: 10),
                  _buildFeatureCard(context, Icons.lock, 'Cambiar contraseña', 'Establece una nueva contraseña segura', Colors.blue),
                  const SizedBox(height: 10),
                  _buildFeatureCard(context, Icons.language, 'Idioma', 'Seleccione el idioma de la aplicación', Colors.blue),
                  const SizedBox(height: 10),
                  _buildFeatureCard(context, Icons.notifications, 'Notificaciones', 'Configura tus preferencias de notificaciones', Colors.orange),
                  const SizedBox(height: 10),
                  _buildFeatureCard(context, Icons.security, 'Privacidad', 'Configura tu privacidad y datos', Colors.green),
                ],
              )
            )
          ],
        ),
      )
    );
  }

  // ✅ Widget para el selector de tema
  Widget _buildThemeSelector() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.palette, size: 30, color: Colors.purple),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tema de la App',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _isDarkMode ? 'Tema oscuro activado' : 'Tema claro activado',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isDarkMode,
              onChanged: _toggleTheme,
              activeColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String description, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Has pulsado "$title"')),
        );
      },
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(description),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}