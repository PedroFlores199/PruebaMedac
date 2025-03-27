import 'package:flutter/material.dart';

class ProductoDetalleScreen extends StatelessWidget {
  final String producto;

  ProductoDetalleScreen({required this.producto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle de $producto')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              producto,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Información nutricional y detalles de $producto',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}