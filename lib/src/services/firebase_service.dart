import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/models/models.dart';

class FirebaseServices {
  static final FirebaseServices instance = FirebaseServices._init();

  FirebaseServices._init();

  final String collectionCartItems = 'cart_items';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Insertar o reemplazar un item en el carrito
  Future<void> insert(CartItem item) async {
    await _db
        .collection(collectionCartItems)
        .doc(item.id.toString())
        .set(item.toMap(), SetOptions(merge: true));
  }

  /// Obtener todos los items del carrito
  Future<List<CartItem>> getAllItems() async {
    final snapshot = await _db.collection(collectionCartItems).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CartItem(
        id: int.parse(doc.id),
        name: data['name'],
        price: data['price'],
        quantity: data['quantity'],
      );
    }).toList();
  }

  /// Eliminar un item por ID
  Future<void> delete(int id) async {
    await _db.collection(collectionCartItems).doc(id.toString()).delete();
  }

  /// Actualizar un item
  Future<void> update(CartItem item) async {
    await _db
        .collection(collectionCartItems)
        .doc(item.id.toString())
        .update(item.toMap());
  }
}
