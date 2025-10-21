import 'package:flutter/material.dart';
import '../../widgets/appbar.dart';
import '../pets/pets.dart';
import '../invoices/history_invoice.dart';
import '../settings/settings.dart';
import '../appointments/appointments.dart';
import '../appointments/agenda.dart';

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
  late String _currentUsername;
  late String _currentEmail;
  late String _currentPassword;

  @override
  void initState() {
    super.initState();
    _currentUsername = widget.username;
    _currentEmail = '${widget.username}@demo.com';
    _currentPassword = widget.password;
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
          currentUsername: _currentUsername,
          currentEmail: _currentEmail,
          currentPassword: _currentPassword,
          onProfileUpdated: (newUsername, newEmail, newPassword) {
            setState(() {
              _currentUsername = newUsername;
              _currentEmail = newEmail;
              _currentPassword = newPassword;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Perfil de usuario', showBackButton: false),
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
           
            // BOTÓN PARA EDITAR PERFIL
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit),
                label: const Text('Editar Perfil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // BOTÓN PARA MOSTRAR/OCULTAR LA INFORMACIÓN DEL PERFIL
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _toggleProfileInfo,
                icon: Icon(_showProfileInfo ? Icons.visibility_off : Icons.visibility),
                label: Text(_showProfileInfo ? 'Ocultar Perfil' : 'Ver Perfil'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple,
                  side: const BorderSide(color: Colors.purple),
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
                      _buildInfoRow('Usuario:', _currentUsername),
                      const SizedBox(height: 10),
                      _buildInfoRow('Email:', _currentEmail),
                      const SizedBox(height: 10),
                      _buildInfoRow('Contraseña:',
                          '${'*' * _currentPassword.length} (${_currentPassword.length} caracteres)'),
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
                  _buildFeatureCard(context, Icons.pets, 'Mascotas', const PetHomePage()),
                  const SizedBox(height: 10),
                  _buildFeatureCard(context, Icons.receipt_long, 'Facturas', const HistorialFacturasScreen()),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    context,
                    Icons.calendar_today,
                    'Citas',
                    const CitasScreen()
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    context,
                    Icons.calendar_month,
                    'Calendario',
                    const AgendaCalendarScreen()
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    context,
                    Icons.settings,
                    'Configuración',
                    SettingsScreen(username: _currentUsername, password: _currentPassword)
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

class EditProfileDialog extends StatefulWidget {
  final String currentUsername;
  final String currentEmail;
  final String currentPassword;
  final Function(String, String, String) onProfileUpdated;

  const EditProfileDialog({
    super.key,
    required this.currentUsername,
    required this.currentEmail,
    required this.currentPassword,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
    _emailController = TextEditingController(text: widget.currentEmail);
    _passwordController = TextEditingController(text: widget.currentPassword);
    _confirmPasswordController = TextEditingController(text: widget.currentPassword);
    _phoneController = TextEditingController(text: '3001234567');
    _addressController = TextEditingController(text: 'Calle 123 #45-67');
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Simular proceso de guardado
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });

        widget.onProfileUpdated(
          _usernameController.text,
          _emailController.text,
          _passwordController.text,
        );

        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Editar Perfil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Usuario
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
                    if (value.length < 3) {
                      return 'El usuario debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su correo electrónico';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Por favor ingrese un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Teléfono
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su teléfono';
                    }
                    if (value.length < 10) {
                      return 'El teléfono debe tener al menos 10 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Dirección
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

                // Contraseña
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
                    if (!RegExp(
                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,16}$',
                    ).hasMatch(value)) {
                      return 'Debe tener entre 8 y 16 caracteres,\ncon al menos una mayúscula, una minúscula,\nun número y un carácter especial';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Confirmar Contraseña
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
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.purple,
                          side: const BorderSide(color: Colors.purple),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}