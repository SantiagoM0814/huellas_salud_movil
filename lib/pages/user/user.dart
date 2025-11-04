import 'package:flutter/material.dart';
import '../../widgets/appbar.dart';
import './users.dart';
import '../pets/pets.dart';
import '../invoices/history_invoice.dart';
import '../auth/login.dart';
import '../appointments/appointments.dart';
import '../appointments/agenda.dart';
import '../settings/settings.dart';


class UserScreen extends StatefulWidget {
  final String username;
  final String password;


  const UserScreen({super.key, required this.username, required this.password});


  @override
  State<UserScreen> createState() => _UserScreenState();
}


class _UserScreenState extends State<UserScreen> {
  bool _showProfileInfo = true;
 
  void _toggleProfileInfo() {
    setState(() {
      _showProfileInfo = !_showProfileInfo;
    });
  }


  void _editProfile() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditProfileDialog(
          username: widget.username,
          password: widget.password,
          onProfileUpdated: () {
            // Aquí puedes agregar lógica para actualizar el perfil si es necesario
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Perfil actualizado exitosamente')),
            );
          },
        );
      },
    );
  }


  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }


  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
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


  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
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
           
            // Botón "Editar Perfil"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit),
                label: const Text('Editar Perfil'),
              ),
            ),
            const SizedBox(height: 10),
           
            // Botón "Ver Perfil" / "Ocultar Perfil"
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _toggleProfileInfo,
                icon: Icon(_showProfileInfo ? Icons.visibility_off : Icons.visibility),
                label: Text(_showProfileInfo ? 'Ocultar Perfil' : 'Ver Perfil'),
              ),
            ),
            const SizedBox(height: 20),


            // Información del perfil (condicional)
            if (_showProfileInfo) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow('Usuario:', widget.username),
                      const SizedBox(height: 15),
                      _buildInfoRow('Email:', '${widget.username}@demo.com'),
                      const SizedBox(height: 15),
                      _buildInfoRow(
                        'Contraseña:',
                        '${'*' * widget.password.length} (${widget.password.length} caracteres)',
                      ),
                      const SizedBox(height: 15),
                      _buildInfoRow('Teléfono:', '+57 300 123 4567'),
                      const SizedBox(height: 15),
                      _buildInfoRow('Dirección:', 'Calle 123 #45-67, Ciudad'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
           
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildFeatureCard(
                    context,
                    Icons.person,
                    'Usuarios',
                    const UserHomePage(),
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    context,
                    Icons.pets,
                    'Mascotas',
                    const PetHomePage(),
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    context,
                    Icons.receipt_long,
                    'Facturas',
                    const HistorialFacturasScreen(),
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    context,
                    Icons.calendar_today,
                    'Citas',
                    const CitasScreen(),
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    context,
                    Icons.calendar_month,
                    'Calendario',
                    const AgendaCalendarScreen(),
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    context,
                    Icons.settings,
                    'Configuración',
                    SettingsScreen(username: widget.username, password: widget.password),
                  ),
                  const SizedBox(height: 10),
                  _buildLogoutCard(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    Widget destinationPage,
  ) {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildLogoutCard(BuildContext context) {
    return InkWell(
      onTap: () => _showLogoutConfirmation(context),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.logout, size: 30, color: Colors.red),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Diálogo para editar perfil
class EditProfileDialog extends StatefulWidget {
  final String username;
  final String password;
  final VoidCallback onProfileUpdated;


  const EditProfileDialog({
    super.key,
    required this.username,
    required this.password,
    required this.onProfileUpdated,
  });


  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}


class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();


  @override
  void initState() {
    super.initState();
    // Inicializar controladores con datos actuales
    _usernameController.text = widget.username;
    _phoneController.text = '+57 300 123 4567';
    _addressController.text = 'Calle 123 #45-67, Ciudad';
    _passwordController.text = widget.password;
  }


  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }


      // Aquí iría la lógica para guardar los cambios en la base de datos
      widget.onProfileUpdated();
      Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Perfil'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su usuario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su teléfono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su dirección';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Nueva Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  prefixIcon: Icon(Icons.lock_clock_outlined),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirme su contraseña';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveProfile,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}