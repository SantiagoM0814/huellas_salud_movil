import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../widgets/appbar.dart';
import '../auth/login.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  static const String apiBase = 'https://huellassalud.onrender.com';

  static const String defaultRole = 'CLIENTE';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _selectedDocumentT = 'Cédula de ciudadania';
  bool _acceptTerms = false;

  final List<String> _tDocument = [
    'Cédula de ciudadania',
    'Cédula de extranjeria',
    'Tarjeta de identidad',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _documentController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _navigationLogin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Uri _buildUrl(String path) {
    final base = apiBase.endsWith('/') ? apiBase.substring(0, apiBase.length - 1) : apiBase;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse(base + normalizedPath);
  }

  // Mapea la etiqueta visible a los códigos que espera la API
  String _mapDocumentType(String label) {
    switch (label) {
      case 'Cédula de ciudadania':
        return 'CC';
      case 'Cédula de extranjeria':
        return 'CE';
      case 'Tarjeta de identidad':
        return 'TI';
      default:
        return label; // si ya viene en formato corto
    }
  }

  Future<void> _register() async {
    if (!_acceptTerms) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes aceptar los Términos y Condiciones'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
      }
      return;
    }

    // Payload adaptado al contrato que mostraste
    final userData = {
      'name': _nameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'documentType': _mapDocumentType(_selectedDocumentT),
      'documentNumber': _documentController.text.trim(),
      'email': _emailController.text.trim(),
      'cellPhone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'password': _passwordController.text,
      'role': defaultRole,
    };

    // Mostrar indicador de carga
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final url = _buildUrl('/internal/user/register');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      // La API espera { "data": { ... } }
      final body = jsonEncode({'data': userData});

      // DEBUG: imprimir request completo
      // ignore: avoid_print
      print('--- REQUEST -> POST $url');
      // ignore: avoid_print
      print('Headers: $headers');
      // ignore: avoid_print
      print('Body: $body');

      final response = await http
          .post(
            url,
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      // DEBUG: imprimir respuesta completa
      // ignore: avoid_print
      print('--- RESPONSE <- ${response.statusCode} ${response.reasonPhrase}');
      // ignore: avoid_print
      print('Response headers: ${response.headers}');
      // ignore: avoid_print
      print('Response body: ${response.body}');

      // Cerrar loading
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseBody;
        try {
          responseBody = jsonDecode(response.body);
        } catch (_) {
          responseBody = null;
        }

        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Registro Exitoso'),
                content: const Text('¡Te has registrado correctamente! por favor validar el correo.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();

                      _formKey.currentState!.reset();
                      _nameController.clear();
                      _lastNameController.clear();
                      _emailController.clear();
                      _passwordController.clear();
                      _documentController.clear();
                      _addressController.clear();
                      _confirmPasswordController.clear();
                      _phoneController.clear();
                      setState(() {
                        _acceptTerms = false;
                      });

                      Navigator.pop(context, responseBody ?? userData);
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        String message = 'Error en el registro. Intenta de nuevo. (${response.statusCode})';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map && errorBody['message'] != null) {
            message = errorBody['message'].toString();
          } else {
            message = '(${response.statusCode}) ${response.body}';
          }
        } catch (_) {
          message = '(${response.statusCode}) ${response.body}';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      }
    } on TimeoutException catch (e) {
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tiempo de espera agotado'), backgroundColor: Colors.red),
        );
      }
      // ignore: avoid_print
      print('Timeout en register: $e');
    } catch (e) {
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de red: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
      // ignore: avoid_print
      print('Exception en register: $e');
    }
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Registro de Usuario',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Image.asset('assets/img/logos/logo.png', height: 100),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombres',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su nombre';
                  }
                  if (value.length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su apellido';
                  }
                  if (value.length < 3) {
                    return 'El apellido debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _selectedDocumentT,
                decoration: const InputDecoration(
                  labelText: 'Tipo de documento',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: _tDocument.map((String tDocument) {
                  return DropdownMenuItem<String>(
                    value: tDocument,
                    child: Text(tDocument),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDocumentT = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _documentController,
                decoration: const InputDecoration(
                  labelText: 'Número de documento',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su número de documento';
                  }
                  if (value.length < 6) {
                    return 'El número de documento es muy corto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

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
              const SizedBox(height: 20),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su teléfono';
                  }
                  if (value.length < 7) {
                    return 'El teléfono es muy corto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  hintText: 'Ej: Calle 45 # 32-16 Apto 201',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(), // opcional, para mejor visual
                ),
                keyboardType: TextInputType.streetAddress,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su dirección';
                  }
                  if (value.length < 10) {
                    return 'La dirección debe tener al menos 10 caracteres';
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
                  if (value.length < 8) {
                    return 'La contraseña debe tener al menos 8 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 30),

              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _showTermsDialog();
                      },
                      child: const Text(
                        'Acepto los Términos y Condiciones',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _acceptTerms ? _register : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Registrarse',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya tienes una cuenta?'),
                  TextButton(
                    onPressed: _navigationLogin,
                    child: const Text('Iniciar Sesión'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Términos y Condiciones'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Aceptación de los Términos',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Al registrarte, aceptas cumplir con estos términos y condiciones.',
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 10),
                Text(
                  'Tu información personal será manejada de acuerdo con nuestra política de privacidad.',
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 20),
                Text(
                  'Debes usar el servicio de manera responsable y no realizar actividades ilegales.',
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}