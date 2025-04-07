import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/prod_provider.dart';
// Añadir la importación de la pantalla de inicio
import 'pantallas/inicio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario para Firebase

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase conectado");
  } catch (e) {
    print("Error en Firebase: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ProductosProvider(),  // Crear provider sin carga inmediata
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cargar productos después de la construcción inicial
    Future.microtask(() => 
      Provider.of<ProductosProvider>(context, listen: false).loadProductos()
    );
    
    return MaterialApp(
      title: 'Inventario DAM',
      theme: ThemeData(useMaterial3: true),
      home: InicioScreen(), // Cambiar a la pantalla de inicio de sesión
    );
  }
}
