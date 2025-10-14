import 'package:flutter/material.dart';
import '../../widgets/appbar.dart';
import './users.dart';
import './user_products.dart'; // ✅ NUEVA IMPORTACIÓN
import '../pets/pets.dart';
import '../invoices/history_invoice.dart';
import '../settings/settings.dart';
import '../auth/login.dart';
import '../appointments/appointments.dart';
import '../appointments/agenda_calendar.dart'; // ✅ NUEVA IMPORTACIÓN

class UserScreen extends StatefulWidget {
  final String username;
  final String password;
  final VoidCallback? onBackPressed;

  const UserScreen({
    super.key,
    required this.username,
    required this.password,
    this.onBackPressed,
  });

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _showProfileInfo = false;

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  void _toggleProfileInfo() {
    setState(() {
      _showProfileInfo = !_showProfileInfo;
    });
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesión cerrada exitosamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Perfil de usuario',
        showBackButton: true,
        onBackPressed: widget.onBackPressed != null
            ? () => widget.onBackPressed!()
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 70, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
           
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleProfileInfo,
                icon: Icon(_showProfileInfo ? Icons.visibility_off : Icons.edit),
                label: Text(_showProfileInfo ? 'Ocultar Perfil' : 'Editar Perfil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (_showProfileInfo) ...[
              Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Mi Perfil',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow('Usuario:', widget.username),
                      const SizedBox(height: 10),
                      _buildInfoRow('Email:', '${widget.username}@demo.com'),
                      const SizedBox(height: 10),
                      _buildInfoRow('Contraseña:',
                          '${'*' * widget.password.length} (${widget.password.length} caracteres)'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
           
            const Text(
              'Otras Opciones',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
           
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildFeatureCard(context, Icons.people, 'Usuarios', const UserHomePage()),
                  const SizedBox(height: 10),
                  _buildFeatureCard(context, Icons.pets, 'Mascotas', const PetHomePage()),
                  const SizedBox(height: 10),
                 
                  // ✅ NUEVO BOTÓN DE AGENDA/CALENDARIO
                  _buildFeatureCard(context, Icons.calendar_today, 'Agenda/Calendario', const AgendaCalendarScreen()),
                  const SizedBox(height: 10),
                 
                  // ✅ NUEVO BOTÓN DE PRODUCTOS
                  _buildFeatureCard(context, Icons.shopping_bag, 'Productos', const UserProductsScreen()),
                  const SizedBox(height: 10),
                  // ✅ NUEVO BOTÓN DE CITAS
                  _buildFeatureCard(context, Icons.calendar_today, 'Citas', const CitasScreen()),
                  const SizedBox(height: 10),
                 
                  _buildFeatureCard(context, Icons.receipt_long, 'Facturas', const HistorialFacturasScreen()),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    context,
                    Icons.settings,
                    'Configuración',
                    SettingsScreen(username: widget.username, password: widget.password)
                  ),
                  const SizedBox(height: 10),
                  _buildLogoutCard(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, Widget destinationPage) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 30, color: Colors.purple),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutCard() {
    return InkWell(
      onTap: _showLogoutConfirmation,
      child: Card(
        elevation: 3,
        color: Colors.red.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.logout, size: 30, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Salir de tu cuenta actual',
                      style: TextStyle(
                        color: Colors.red.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}