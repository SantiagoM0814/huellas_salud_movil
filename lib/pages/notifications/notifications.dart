import 'dart:convert';
import 'package:flutter/material.dart';
import '../../widgets/appbar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Aquí van las notificaciones'),
      ),
    );
  }
}

