class Product {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imageURL;

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imageURL,
  });

  /// Convertir el producto a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imageURL': imageURL,
    };
  }

  /// Crear una instancia de Product desde un Map
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      imageURL: map['imageURL'] ?? '',
    );
  }

  /// Crear una copia del producto con algunos campos modificados
  Product copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    double? precio,
    String? imageURL,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      imageURL: imageURL ?? this.imageURL,
    );
  }
}