import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseProductosRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todos los productos (Stream para updates en tiempo real)
  Stream<List<Map<String, dynamic>>> getProductosStream() {
    return _firestore.collection('productos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  // Obtener productos una sola vez (Future para carga inicial)
  Future<List<Map<String, dynamic>>> getProductosFuture() async {
    final snapshot = await _firestore.collection('productos').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }
}
