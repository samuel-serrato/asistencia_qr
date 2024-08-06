import 'package:asistencia_qr/screens/home.dart';
import 'package:asistencia_qr/screens/listaAlumnos.dart';
import 'package:asistencia_qr/screens/listaAsistencia.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
  initializeDateFormatting('es_ES', null); // Inicializa la localización
  Intl.defaultLocale = 'es_ES'; // Establece la localización por defecto
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.red,
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
        ).copyWith(
          secondary: Colors.red,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => QRScannerPage(),
        '/screen1': (context) => ListaAlumnos(),
        '/screen2': (context) => ListaAsistencia(),
      },
    );
  }
}
