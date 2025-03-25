import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  String? id; // Para el ID del documento en Firestore
  String titulo;
  String descripcion;
  String categoria;
  int stock;
  double precio;

  Producto({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.stock,
    required this.precio,
  });

  // Convertimos un producto a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'stock': stock,
      'precio': precio,
    };
  }

  // Combertimos un mapa de Firestore a un producto
  factory Producto.fromMap(Map<String, dynamic> map, String docId) {
    return Producto(
      id: docId,
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      categoria: map['categoria'] ?? '',
      stock: map['stock'] ?? 0,
      precio: (map['precio'] ?? 0).toDouble(),
    );
  }
}

class ProductosScreen extends StatefulWidget {
  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final CollectionReference _productosCollection = 
      FirebaseFirestore.instance.collection('productos');
  
  // Controladores de texto
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _stockController = TextEditingController();
  final _precioController = TextEditingController();
  
  // Controlador de búsqueda
  final _searchController = TextEditingController();
  String _searchQuery = "";
  
  String? _editingId;
  
  void _resetControllers() {
    _tituloController.clear();
    _descripcionController.clear();
    _categoriaController.clear();
    _stockController.clear();
    _precioController.clear();
    _editingId = null;
  }
  
  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _categoriaController.dispose();
    _stockController.dispose();
    _precioController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _showProductDialog({Producto? producto}) {
    _editingId = producto?.id;
    
    // Si se esta editando un producto, rellenamos los campos con el texto correspondiente a esa ficha
    if (producto != null) {
      _tituloController.text = producto.titulo;
      _descripcionController.text = producto.descripcion;
      _categoriaController.text = producto.categoria;
      _stockController.text = producto.stock.toString();
      _precioController.text = producto.precio.toString();
    } else {
      _resetControllers();
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(producto != null ? 'Editar Producto' : 'Nuevo Producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: 'Título'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _categoriaController,
                decoration: InputDecoration(labelText: 'Categoría'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Stock'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _precioController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Precio'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              // Se podra guardar unicamente si el titulo no esta vacio
              if (_tituloController.text.isNotEmpty) {
                int stock = int.tryParse(_stockController.text) ?? 0;
                double precio = double.tryParse(_precioController.text) ?? 0.0;
                
                Producto producto = Producto(
                  id: _editingId,
                  titulo: _tituloController.text,
                  descripcion: _descripcionController.text,
                  categoria: _categoriaController.text,
                  stock: stock,
                  precio: precio,
                );
                
                // Despues de guardar, cerramos el dialogo
                Navigator.pop(context);
                
                try {
                  print("Intentando guardar en Firestore...");
                  if (_editingId != null) {
                    // Actualizar producto existente
                    await _productosCollection.doc(_editingId).update(producto.toMap());
                    print("Documento actualizado con ID: $_editingId");
                  } else {
                    // Añadir nuevo producto
                    DocumentReference docRef = await _productosCollection.add(producto.toMap());
                    print("Documento creado con ID: ${docRef.id}");
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Producto guardado correctamente')),
                  );
                } catch (e) {
                  print("Error en operación Firestore: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al guardar: $e')),
                  );
                }
              } else {
                // Close dialog even if title is empty
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Por favor, introduce un título')),
                );
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteProduct(String id) async {
    try {
      await _productosCollection.doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto eliminado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
      ),
      body: Column(
        children: [
          // Barra de busqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar productos',
                hintText: 'Introduce el nombre del producto',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = "";
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Listado de productos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _productosCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No hay productos. Añade uno nuevo.'));
                }

                // Filtramos los producto en base a lo que se ha introducido en el campo de busqueda
                List<Producto> productos = snapshot.data!.docs
                    .map((doc) => Producto.fromMap(
                          doc.data() as Map<String, dynamic>,
                          doc.id,
                        ))
                    .where((producto) => 
                        _searchQuery.isEmpty ||
                        producto.titulo.toLowerCase().contains(_searchQuery))
                    .toList();
                
                if (productos.isEmpty) {
                  return Center(child: Text('No se encontraron productos con ese nombre'));
                }

                return ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    Producto producto = productos[index];
                    
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    producto.titulo,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(producto.descripcion),
                                  SizedBox(height: 4),
                                  Text('Categoría: ${producto.categoria}'),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text('Stock: ${producto.stock}'),
                                      ),
                                      Text('Precio: €${producto.precio.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Iconos de edicion y eliminacion
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showProductDialog(producto: producto),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteProduct(producto.id!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        child: Icon(Icons.add),
      ),
    );
  }
}