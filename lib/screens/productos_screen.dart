import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prod_provider.dart';
import 'producto_detalle_screen.dart';

class ProductosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productosProvider = Provider.of<ProductosProvider>(context);

    if (productosProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario DAM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => productosProvider.loadProductos(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: productosProvider.productos.length,
          itemBuilder: (context, index) {
            final producto = productosProvider.productos[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductoDetalleScreen(producto: producto),
                ),
              ),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del producto
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.inventory, size: 40),
                      ),
                      const SizedBox(height: 8),
                      // Título del producto
                      Text(
                        producto['titulo'] ?? 'Sin título',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Precio
                      Text(
                        '${producto['precio']?.toStringAsFixed(2) ?? '0.00'}€',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Stock
                      Text(
                        'Stock: ${producto['stock']?.toString() ?? '0'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: (producto['stock'] ?? 0) <= 5
                              ? Colors.red
                              : Colors.grey[700],
                        ),
                      ),
                    ],
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
