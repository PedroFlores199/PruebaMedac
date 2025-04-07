import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inicio.dart';
import 'productos_detalles.dart';

class Producto {
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final int stock;
  final double precio;

  Producto({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.stock,
    required this.precio,
  });

  // Factory para convertir de Firestore a Producto
  factory Producto.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Producto(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      categoria: data['categoria'] ?? '',
      stock: data['stock'] ?? 0,
      precio: (data['precio'] ?? 0).toDouble(),
    );
  }

  // Factory para covertir Producto a Map para Firestore 
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'stock': stock,
      'precio': precio,
    };
  }
}

class ProductosScreen extends StatefulWidget {
  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Producto> _productos = [];
  List<Producto> _productosFiltrados = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _cargarProductos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargamos productos desde Firestore directamente
      QuerySnapshot snapshot = await _firestore.collection('productos').get();
      
      setState(() {
        _productos = snapshot.docs.map((doc) => Producto.fromFirestore(doc)).toList();
        _productosFiltrados = _productos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar productos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filtrarProductos(String query) {
    setState(() {
      if (query.isEmpty) {
        _productosFiltrados = _productos;
      } else {
        _productosFiltrados = _productos
            .where((p) => p.titulo.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _cerrarSesion(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => InicioScreen()),
    );
  }

  void _editarProducto(BuildContext context, Producto producto) {
    TextEditingController tituloController = TextEditingController(text: producto.titulo);
    TextEditingController descripcionController = TextEditingController(text: producto.descripcion);
    TextEditingController categoriaController = TextEditingController(text: producto.categoria);
    TextEditingController stockController = TextEditingController(text: producto.stock.toString());
    TextEditingController precioController = TextEditingController(text: producto.precio.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: categoriaController,
                decoration: InputDecoration(labelText: 'Categoría'),
              ),
              TextField(
                controller: stockController,
                decoration: InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: precioController,
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              try {
                // Actualizar en Firestore
                await _firestore.collection('productos').doc(producto.id).update({
                  'titulo': tituloController.text,
                  'descripcion': descripcionController.text,
                  'categoria': categoriaController.text,
                  'stock': int.parse(stockController.text),
                  'precio': double.parse(precioController.text),
                });
                
                _cargarProductos();
                Navigator.pop(context);
              } catch (e) {
                print('Error al actualizar producto: $e');
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _eliminarProducto(BuildContext context, Producto producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar producto'),
        content: Text('¿Estás seguro de eliminar ${producto.titulo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Eliminacion del producto en Firestore
                await _firestore.collection('productos').doc(producto.id).delete();
                
                // Actualizamos los productos de nuevo 
                _cargarProductos();
                Navigator.pop(context);
              } catch (e) {
                print('Error al eliminar producto: $e');
              }
            },
            child: Text('Eliminar'),
          ),
        ],
      ),
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
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
              ),
              onChanged: _filtrarProductos,
            ),
          ),
          
          // Lista de productos
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _productosFiltrados.isEmpty
                    ? Center(child: Text('No se encontraron productos'))
                    : ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: _productosFiltrados.length,
                        itemBuilder: (context, index) {
                          final producto = _productosFiltrados[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => 
                                      ProductoDetalleScreen(producto: producto),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            producto.titulo,
                                            style: TextStyle(
                                              fontSize: 18, 
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            producto.descripcion,
                                            style: TextStyle(fontSize: 14),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Categoría: ${producto.categoria}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Stock: ${producto.stock}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Precio: ${producto.precio.toStringAsFixed(2)} €',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Botones de acción (derecha)
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () => _editarProducto(context, producto),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () => _eliminarProducto(context, producto),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Este botón esta abajo a la derecha y añade un nuevo producto
          TextEditingController tituloController = TextEditingController();
          TextEditingController descripcionController = TextEditingController();
          TextEditingController categoriaController = TextEditingController();
          TextEditingController stockController = TextEditingController();
          TextEditingController precioController = TextEditingController();

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Añadir nuevo producto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloController,
                      decoration: InputDecoration(labelText: 'Título'),
                    ),
                    TextField(
                      controller: descripcionController,
                      decoration: InputDecoration(labelText: 'Descripción'),
                    ),
                    TextField(
                      controller: categoriaController,
                      decoration: InputDecoration(labelText: 'Categoría'),
                    ),
                    TextField(
                      controller: stockController,
                      decoration: InputDecoration(labelText: 'Stock'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: precioController,
                      decoration: InputDecoration(labelText: 'Precio'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                    try {
                      if (tituloController.text.isEmpty) return;
                      
                      // Añadimos el producto a Firestore
                      await _firestore.collection('productos').add({
                        'titulo': tituloController.text,
                        'descripcion': descripcionController.text,
                        'categoria': categoriaController.text,
                        'stock': int.tryParse(stockController.text) ?? 0,
                        'precio': double.tryParse(precioController.text) ?? 0.0,
                      });
                      
                      _cargarProductos();
                      Navigator.pop(context);
                    } catch (e) {
                      print('Error al añadir producto: $e');
                    }
                  },
                  child: Text('Añadir'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
