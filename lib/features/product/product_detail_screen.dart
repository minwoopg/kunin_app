import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상품상세')),
      body: Center(child: Text('상품 상세 - ID: $productId')),
    );
  }
}
