
// Экран избранного
import 'package:flutter/material.dart';
import 'package:foodzone/detailFood_%20screen.dart';
import 'package:foodzone/main.dart';

class FavoritesScreen extends StatelessWidget {
  final List<dynamic> favoriteProducts;
  final Function(dynamic) toggleFavorite;

  FavoritesScreen({required this.favoriteProducts, required this.toggleFavorite});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Избранное'),
      ),
      body:
      ListView.builder(
        itemCount: favoriteProducts.length,
        itemBuilder: (context, index) {
          final product = favoriteProducts[index];
          return ListTile(
            leading:
            Image.network(product['image_url']),
            title:
            Text(product['name']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product, isFavorite: true, toggleFavorite: toggleFavorite),
                ),
              );
            },
          );
        },
      ),
    );
  }
}