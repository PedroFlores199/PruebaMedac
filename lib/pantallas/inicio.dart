import 'package:flutter/material.dart';
import 'productos.dart';

class InicioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductosScreen()),
            );
          },
          child: Text('Iniciar sesion'),
        ),
      ),
    );
  }
}