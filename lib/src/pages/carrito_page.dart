import 'package:flutter/material.dart';


class CarritoPage extends StatelessWidget {
  const CarritoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus productos en el Carrito', style: TextStyle(fontSize: 17),),
      ),
      body: const Center(
        child: Text('Contenido del Carrito de Compras'),
      ),
    );
  }
}