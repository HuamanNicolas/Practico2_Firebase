import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../pages/models/producto.dart';

class FirebaseServices {
  static final FirebaseServices instance = FirebaseServices._init();

  FirebaseServices._init();

  final String collectionProducts = 'productos';
  final String collectionCarrito = 'carrito';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== MÉTODOS PARA PRODUCTOS ==========

  /// Convertir imagen a Base64
  Future<String> imageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  /// Convertir Uint8List a Base64 (para web)
  String uint8ListToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  /// Obtener todos los productos
  Future<List<Product>> getAllProducts() async {
    final snapshot = await _db.collection(collectionProducts).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product(
        id: doc.id,
        nombre: data['nombre'] ?? '',
        descripcion: data['descripcion'] ?? '',
        precio: (data['precio'] ?? 0).toDouble(),
        imageURL: data['imageURL'] ?? '',
      );
    }).toList();
  }

  /// Obtener un producto por ID
  Future<Product?> getProductById(String id) async {
    final doc = await _db.collection(collectionProducts).doc(id).get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    return Product(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      imageURL: data['imageURL'] ?? '',
    );
  }

  /// Insertar un nuevo producto con imagen
  Future<String> insertProductWithImage(
    Product product,
    File? imageFile,
  ) async {
    String imageBase64 = '';

    if (imageFile != null) {
      imageBase64 = await imageToBase64(imageFile);
    }

    final productWithImage = Product(
      id: product.id,
      nombre: product.nombre,
      descripcion: product.descripcion,
      precio: product.precio,
      imageURL: imageBase64,
    );

    final docRef = await _db
        .collection(collectionProducts)
        .add(productWithImage.toMap());
    return docRef.id;
  }

  /// Insertar un nuevo producto con imagen desde bytes (para web)
  Future<String> insertProductWithImageBytes(
    Product product,
    Uint8List? imageBytes,
  ) async {
    String imageBase64 = '';

    if (imageBytes != null) {
      imageBase64 = uint8ListToBase64(imageBytes);
    }

    final productWithImage = Product(
      id: product.id,
      nombre: product.nombre,
      descripcion: product.descripcion,
      precio: product.precio,
      imageURL: imageBase64,
    );

    final docRef = await _db
        .collection(collectionProducts)
        .add(productWithImage.toMap());
    return docRef.id;
  }

  /// Insertar un nuevo producto
  Future<String> insertProduct(Product product) async {
    final docRef = await _db
        .collection(collectionProducts)
        .add(product.toMap());
    return docRef.id;
  }

  /// Actualizar un producto existente
  Future<void> updateProduct(Product product) async {
    await _db
        .collection(collectionProducts)
        .doc(product.id)
        .update(product.toMap());
  }

  /// Actualizar producto con nueva imagen
  Future<void> updateProductWithImage(Product product, File? imageFile) async {
    String imageBase64 = product.imageURL;

    if (imageFile != null) {
      imageBase64 = await imageToBase64(imageFile);
    }

    final productWithImage = Product(
      id: product.id,
      nombre: product.nombre,
      descripcion: product.descripcion,
      precio: product.precio,
      imageURL: imageBase64,
    );

    await _db
        .collection(collectionProducts)
        .doc(product.id)
        .update(productWithImage.toMap());
  }

  /// Eliminar un producto por ID
  Future<void> deleteProduct(String id) async {
    await _db.collection(collectionProducts).doc(id).delete();
  }

  /// Obtener productos con filtro por precio
  Future<List<Product>> getProductsByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    final snapshot = await _db
        .collection(collectionProducts)
        .where('precio', isGreaterThanOrEqualTo: minPrice)
        .where('precio', isLessThanOrEqualTo: maxPrice)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product(
        id: doc.id,
        nombre: data['nombre'] ?? '',
        descripcion: data['descripcion'] ?? '',
        precio: (data['precio'] ?? 0).toDouble(),
        imageURL: data['imageURL'] ?? '',
      );
    }).toList();
  }

  /// Buscar productos por nombre
  Future<List<Product>> searchProductsByName(String searchTerm) async {
    final snapshot = await _db
        .collection(collectionProducts)
        .where('nombre', isGreaterThanOrEqualTo: searchTerm)
        .where('nombre', isLessThan: searchTerm + 'z')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product(
        id: doc.id,
        nombre: data['nombre'] ?? '',
        descripcion: data['descripcion'] ?? '',
        precio: (data['precio'] ?? 0).toDouble(),
        imageURL: data['imageURL'] ?? '',
      );
    }).toList();
  }

  // ========== MÉTODOS PARA CARRITO (ACTUALIZADOS) ==========

  /// Agregar producto al carrito con datos completos
  Future<String> addToCarrito(Product product, {int cantidad = 1}) async {
    final docRef = await _db.collection(collectionCarrito).add({
      'productoId': product.id,
      'nombre': product.nombre,
      'descripcion': product.descripcion,
      'precio': product.precio,
      'imageUrl': product.imageURL,
      'cantidad': cantidad,
    });

    return docRef.id;
  }

  /// Obtener todos los items del carrito
  Future<List<Map<String, dynamic>>> getCarritoItems() async {
    final snapshot = await _db.collection(collectionCarrito).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'carritoId': doc.id,
        'productoId': data['productoId'] ?? '',
        'nombre': data['nombre'] ?? '',
        'descripcion': data['descripcion'] ?? '',
        'precio': (data['precio'] ?? 0).toDouble(),
        'imageUrl': data['imageUrl'] ?? '',
        'cantidad': data['cantidad'] ?? 1,
      };
    }).toList();
  }

  /// Obtener productos del carrito como lista de Product
  Future<List<Product>> getCarritoProducts() async {
    final carritoItems = await getCarritoItems();

    return carritoItems.map((item) {
      return Product(
        id: item['productoId'],
        nombre: item['nombre'],
        descripcion: item['descripcion'],
        precio: item['precio'],
        imageURL: item['imageUrl'],
      );
    }).toList();
  }

  /// Verificar si un producto está en el carrito y obtener el carritoId
  Future<String?> getCarritoIdForProduct(String productId) async {
    final snapshot = await _db
        .collection(collectionCarrito)
        .where('productoId', isEqualTo: productId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    }
    return null;
  }

  /// Agregar al carrito o incrementar cantidad si ya existe
  Future<String> addOrIncrementInCarrito(Product product) async {
    final existingCarritoId = await getCarritoIdForProduct(product.id);

    if (existingCarritoId != null) {
      await incrementCantidad(existingCarritoId);
      return existingCarritoId;
    } else {
      return await addToCarrito(product);
    }
  }

  /// Actualizar cantidad específica en carrito
  Future<void> updateCantidadCarrito(String carritoId, int nuevaCantidad) async {
    if (nuevaCantidad <= 0) {
      await removeFromCarrito(carritoId);
    } else {
      await _db.collection(collectionCarrito).doc(carritoId).update({
        'cantidad': nuevaCantidad,
      });
    }
  }

  /// Incrementar cantidad de producto en carrito
  Future<void> incrementCantidad(String carritoId) async {
    final doc = await _db.collection(collectionCarrito).doc(carritoId).get();
    if (doc.exists) {
      final cantidadActual = doc.data()?['cantidad'] ?? 1;
      await updateCantidadCarrito(carritoId, cantidadActual + 1);
    }
  }

  /// Decrementar cantidad de producto en carrito
  Future<void> decrementCantidad(String carritoId) async {
    final doc = await _db.collection(collectionCarrito).doc(carritoId).get();
    if (doc.exists) {
      final cantidadActual = doc.data()?['cantidad'] ?? 1;
      await updateCantidadCarrito(carritoId, cantidadActual - 1);
    }
  }

  /// Eliminar producto del carrito por ID de carrito
  Future<void> removeFromCarrito(String carritoId) async {
    await _db.collection(collectionCarrito).doc(carritoId).delete();
  }

  /// Eliminar todas las instancias de un producto del carrito
  Future<void> removeProductFromCarrito(String productId) async {
    final carritoSnapshot = await _db
        .collection(collectionCarrito)
        .where('productoId', isEqualTo: productId)
        .get();

    for (var doc in carritoSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Limpiar todo el carrito
  Future<void> clearCarrito() async {
    final carritoSnapshot = await _db.collection(collectionCarrito).get();

    for (var doc in carritoSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Contar total de productos en el carrito (suma de cantidades)
  Future<int> getCarritoCount() async {
    final snapshot = await _db.collection(collectionCarrito).get();
    int totalCount = 0;
    
    for (var doc in snapshot.docs) {
      final cantidad = doc.data()['cantidad'] ?? 1;
      totalCount += cantidad as int;
    }
    
    return totalCount;
  }

  /// Contar tipos de productos únicos en carrito
  Future<int> getCarritoUniqueCount() async {
    final snapshot = await _db.collection(collectionCarrito).get();
    return snapshot.docs.length;
  }

  /// Verificar si un producto está en el carrito
  Future<bool> isProductInCarrito(String productId) async {
    final carritoId = await getCarritoIdForProduct(productId);
    return carritoId != null;
  }

  /// Calcular total del carrito
  Future<double> calcularTotalCarrito() async {
    final carritoItems = await getCarritoItems();
    double total = 0;

    for (var item in carritoItems) {
      final precio = item['precio'] as double;
      final cantidad = item['cantidad'] as int;
      total += precio * cantidad;
    }

    return total;
  }

  /// Obtener stream del carrito en tiempo real
  Stream<List<Map<String, dynamic>>> getCarritoStream() {
    return _db.collection(collectionCarrito).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'carritoId': doc.id,
          'productoId': data['productoId'] ?? '',
          'nombre': data['nombre'] ?? '',
          'descripcion': data['descripcion'] ?? '',
          'precio': (data['precio'] ?? 0).toDouble(),
          'imageUrl': data['imageUrl'] ?? '',
          'cantidad': data['cantidad'] ?? 1,
        };
      }).toList();
    });
  }

  /// Obtener cantidad específica de un producto en carrito
  Future<int> getCantidadProductoEnCarrito(String productId) async {
    final carritoId = await getCarritoIdForProduct(productId);
    if (carritoId == null) return 0;

    final doc = await _db.collection(collectionCarrito).doc(carritoId).get();
    if (doc.exists) {
      return doc.data()?['cantidad'] ?? 0;
    }
    return 0;
  }
}
