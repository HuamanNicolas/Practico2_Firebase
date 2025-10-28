import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practico2_firebase/src/pages/models/producto.dart';
import 'package:practico2_firebase/src/services/firebase_service.dart';

class ProductoPage extends StatefulWidget {
  const ProductoPage({super.key});

  @override
  State<ProductoPage> createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  final FirebaseServices _firebaseServices = FirebaseServices.instance;
  File? _image;

  

  Future<void> _pickImage({required bool fromCamera}) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: fromCamera ? ImageSource.camera : ImageSource.gallery, imageQuality: 50, maxWidth: 800);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Product>>(
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 86, 9, 105),
        onPressed: () => _showAddProductDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
            'No hay productos',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Agrega un producto con el botón +',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
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
          'Lista de Productos',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 16),
        ...products.map((product) => _buildProductCard(product)),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    ImageProvider imageProvider;
    final imageUrl = product.imageURL;

    try {
      if (imageUrl.isNotEmpty) {
        final imageBytes = base64Decode(imageUrl);
        imageProvider = MemoryImage(imageBytes);
      } else {
        imageProvider = const AssetImage('assets/placeholder.png'); // Fallback image
      }
    } catch (e) {
      imageProvider = const AssetImage('assets/placeholder.png'); // Fallback on any error
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.descripcion,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color.fromARGB(255, 95, 9, 98)),
                  onPressed: () => _showEditProductDialog(context, product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDeleteProduct(context, product.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final precioController = TextEditingController();
    _image = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Producto'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
                  ),
                  TextFormField(
                    controller: descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                     validator: (value) => value!.isEmpty ? 'Ingrese una descripción' : null,
                  ),
                  TextFormField(
                    controller: precioController,
                    decoration: const InputDecoration(labelText: 'Precio', prefixText: '\$'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Ingrese un precio' : null,
                  ),
                  const SizedBox(height: 12),
                 StatefulBuilder(
  builder: (BuildContext context, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imagen',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
            color: Color.fromARGB(255, 38, 37, 37),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Área de texto tipo TextField
              Expanded(
                child: _image != null
                    ? Text(
                        _image!.path.split('/').last, // Nombre de la imagen
                        style: const TextStyle(fontSize: 16),
                      )
                    : const Text(
                        'Seleccione o tome una foto',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 8),
              // Botón de cámara
              IconButton(
                icon: const Icon(Icons.camera_alt, color: Color.fromARGB(255, 111, 9, 109)),
                onPressed: () async {
                  await _pickImage(fromCamera: true);
                  setState(() {});
                },
              ),
              // Botón de galería
              IconButton(
                icon: const Icon(Icons.photo_library, color: Color.fromARGB(255, 111, 9, 109)),
                onPressed: () async {
                  await _pickImage(fromCamera: false);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        // Vista previa de la imagen
        if (_image != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Image.file(_image!, height: 150),
          ),
      ],
    );
  },
),



                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newProduct = Product(
                    id: '', // Firestore will generate the ID
                    nombre: nombreController.text,
                    descripcion: descripcionController.text,
                    precio: double.parse(precioController.text),
                    imageURL: '', // The service will handle the image
                  );
                  
                  await _firebaseServices.insertProductWithImage(newProduct, _image);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto agregado')),
                  );
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: product.nombre);
    final descripcionController = TextEditingController(text: product.descripcion);
    final precioController = TextEditingController(text: product.precio.toString());
    _image = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Producto'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
                  ),
                  TextFormField(
                    controller: descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    validator: (value) => value!.isEmpty ? 'Ingrese una descripción' : null,
                  ),
                  TextFormField(
                    controller: precioController,
                    decoration: const InputDecoration(labelText: 'Precio', prefixText: '\$'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Ingrese un precio' : null,
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Column(
                        children: [
                           _image != null
                              ? Image.file(_image!, height: 150)
                              : (product.imageURL.isNotEmpty
                                  ? Image.memory(
                                      base64Decode(product.imageURL.split(',').last),
                                      height: 150,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.image_not_supported, size: 100);
                                      },
                                    )
                                  : const Icon(Icons.image_not_supported, size: 100)),
                          TextButton(
                            onPressed: () async {
                              await _pickImage(fromCamera: false);
                              setState(() {});
                            },
                            child: const Text('Cambiar Foto'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final updatedProduct = product.copyWith(
                    nombre: nombreController.text,
                    descripcion: descripcionController.text,
                    precio: double.parse(precioController.text),
                  );

                  await _firebaseServices.updateProductWithImage(updatedProduct, _image);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto actualizado')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteProduct(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este producto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await _firebaseServices.deleteProduct(productId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Producto eliminado')),
                );
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
