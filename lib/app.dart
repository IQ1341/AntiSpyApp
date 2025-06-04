import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AntiSpy Camera',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData.dark(), // atau custom ThemeData sesuai kebutuhan
      initialRoute: '/',       // route awal (SplashScreen)
      routes: AppRoutes.routes, // gunakan AppRoutes versi bawaan MaterialApp
    );
  }
}
