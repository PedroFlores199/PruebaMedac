import 'package:flutter/material.dart';
import '../services/firebase_productos_repository.dart';

class ProductosProvider with ChangeNotifier {
  final FirebaseProductosRepository _repository = FirebaseProductosRepository();
  List<Map<String, dynamic>> _productos = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get productos => _productos;
  bool get isLoading => _isLoading;

  Future<void> loadProductos() async {
    try {
      _isLoading = true;
      notifyListeners(); // Notifica a los widgets para mostrar loading

      _productos = await _repository.getProductosFuture();
    } catch (e) {
      print("Error cargando productos: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifica que los datos están listos
    }
  }
}
