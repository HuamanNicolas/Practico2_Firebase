import 'package:flutter/material.dart';

class Shopping extends StatelessWidget {
  const Shopping({super.key, required this.title});

  final String title;

  //productos de ejemplo
  final List<Map<String, dynamic>> products = const [
    {
      'id': 1,
      'name': 'Producto 1',
      'description': 'Descripción del Producto 1',
      'price': 10.0,
      'image': 'https://via.placeholder.com/150/FF6B6B/FFFFFF?text=Producto+1'
    },
    {
      'id': 2,
      'name': 'Producto 2',
      'description': 'Descripción del Producto 2',
      'price': 20.0,
      'image': 'https://via.placeholder.com/150/4ECDC4/FFFFFF?text=Producto+2'
    },
    {
      'id': 3,
      'name': 'Producto 3',
      'description': 'Descripción del Producto 3',
      'price': 30.0,
      'image': 'https://via.placeholder.com/150/45B7D1/FFFFFF?text=Producto+3'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 86, 9, 105),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Bienvenido',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          ...listaProductos(),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          
        ),
      ),
    );
  }

  Widget cardItem(String name, double price, String imageUrl) {
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
              child: Image.network(
                imageUrl,
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
                    name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
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
                // Lógica para agregar al carrito
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> listaProductos() {
    return products
        .map((product) => cardItem(
              product['name'],
              product['price'],
              product['image'],
            ))
        .toList();
  }

}