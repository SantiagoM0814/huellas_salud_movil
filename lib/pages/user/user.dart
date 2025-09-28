import 'package:flutter/material.dart';
import '../../widgets/appbar.dart';
import './users.dart';
import '../pets/pets.dart';
import '../invoices/history_invoice.dart';
import '../settings/settings.dart';

class UserScreen extends StatefulWidget {
  final String username;
  final String password;

  const UserScreen({
    super.key,
    required this.username,
    required this.password,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Perfil de usuario', showBackButton: true),
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
           
            // BOTÓN PARA MOSTRAR/OCULTAR LA INFORMACIÓN DEL PERFIL
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

            // INFORMACIÓN DEL PERFIL (SOLO SE MUESTRA AL PRESIONAR EL BOTÓN)
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
           
            // Lista de opciones
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
                  _buildFeatureCard(context, Icons.receipt_long, 'Facturas', const HistorialFacturasScreen()),
                  const SizedBox(height: 10),
                  // CONFIGURACIÓN - Ahora va a SettingsScreen
                  _buildFeatureCard(
                    context, 
                    Icons.settings, 
                    'Configuración', 
                    SettingsScreen(username: widget.username, password: widget.password)
                  ),
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
}