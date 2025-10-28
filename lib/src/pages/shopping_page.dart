import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:practico2_firebase/src/pages/models/producto.dart';
import 'package:practico2_firebase/src/services/firebase_service.dart';
import 'producto_page.dart';
import 'carrito_page.dart';

class Shopping extends StatefulWidget {
  const Shopping({super.key, required this.title});

  final String title;

  @override
  State<Shopping> createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
  int _selectedIndex = 0;
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  @override
  Widget build(BuildContext context) {
    // 👇 Las páginas se crean dentro del build (no antes)
    final pages = [
      _vistaShopping(),
      const CarritoPage(),
      const ProductoPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 86, 9, 105),
        title: Text(
          _getTitle(),
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 86, 9, 105),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shopping',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Productos',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Shopping';
      case 1:
        return 'Carrito de Compras';
      case 2:
        return 'Administración de Productos';
      default:
        return 'Shopping';
    }
  }

  // 👇 Vista principal con StreamBuilder para productos
  Widget _vistaShopping() {
  return StreamBuilder<List<Product>>(
    stream: _firebaseServices.getProductsStream(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return _buildEmptyProductList();
      }

      final products = snapshot.data!;
      return _buildProductList(products);
    },
  );
}


  Widget _buildEmptyProductList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No hay productos disponibles',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Bienvenido a mi tienda',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 16),
        ...products.map((product) => cardItem(product)),
      ],
    );
  }

  Widget cardItem(Product product) {
    ImageProvider imageProvider;
    final imageUrl = product.imageURL;

    try {
      if (imageUrl.isNotEmpty) {
        final imageBytes = base64Decode(imageUrl);
        imageProvider = MemoryImage(imageBytes);
      } else {
        imageProvider = const AssetImage('assets/placeholder.png');
      }
    } catch (e) {
      imageProvider = const AssetImage('assets/placeholder.png');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: imageProvider,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 40),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 82, 18, 79),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_shopping_cart, color: Colors.blue),
              iconSize: 28,
              onPressed: () {
                _firebaseServices.addOrIncrementInCarrito(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Producto agregado al carrito')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
