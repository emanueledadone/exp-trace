import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'pages/home_page.dart';

void main() {
  // Controlla la piattaforma
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Su Android e iOS, non è necessaria nessuna configurazione speciale
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestione Conti',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

bool isValidText(String text) {
  return text.isNotEmpty;
}

String sanitizeBalance(String balance) {
  return balance.replaceAll(',', '.');
}

bool isValidNumber(String value) {
  return RegExp(r'^\d+(\.\d+)?$').hasMatch(value);
}

Future<void> navigateTo(BuildContext context, Widget page) async {
  await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}
