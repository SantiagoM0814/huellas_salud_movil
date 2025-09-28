import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/splash/splash_app.dart';
import 'theme/theme_app.dart';
import 'theme/theme_provider.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Huellas & Salud',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),  
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}