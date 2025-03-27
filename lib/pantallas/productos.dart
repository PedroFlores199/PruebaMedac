import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'inicio.dart';
import 'productos_detalles.dart';

class ProductosScreen extends StatelessWidget {
  final List<String> productos = ['Manzana', 'Banana', 'Zanahoria', 'Nueces', 'Avena', 'Leche'];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _cerrarSesion(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => InicioScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuestros Productos'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _cerrarSesion(context), // Cerrar sesión
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
          ),
          itemCount: productos.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductoDetalleScreen(producto: productos[index])),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    productos[index],
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
