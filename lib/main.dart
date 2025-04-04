import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/prod_provider.dart';
import 'screens/productos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario para Firebase

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase conectado");
  } catch (e) {
    print("❌ Error en Firebase: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ProductosProvider()
        ..loadProductos(), // Carga los productos al iniciar
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario DAM',
      theme: ThemeData(useMaterial3: true),
      home: ProductosScreen(), // Pantalla principal
    );
  }
}
