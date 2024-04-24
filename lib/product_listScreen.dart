import 'package:foodzone/category_ListScreen.dart';
import 'package:foodzone/favorite_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodzone/main.dart';


// Каталог,состояние
class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

// главный экран Каталога
class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<dynamic>> _productsFuture;
  List<dynamic> _favoriteProducts = [];
  final TextEditingController _searchController = TextEditingController(); // для Поийска

  @override
  void initState() {
    super.initState();
    _productsFuture = fetchProducts();
  }
// ассинхронный метод
  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('https://uvlfpiijmtcpjdunxiwg.supabase.co/rest/v1/products?select=*'),
      headers: {
        'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV2bGZwaWlqbXRjcGpkdW54aXdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTM4OTY1MzMsImV4cCI6MjAyOTQ3MjUzM30.xlpxQBJhQhBHBoHeke-hE7CRamMYNmHXGz1dudDp25I',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Ничего не нашёл :(');
    }
  }
  // избранное при нажатии
  void toggleFavorite(dynamic product) {
    setState(() {
      if (_favoriteProducts.contains(product)) {
        _favoriteProducts.remove(product);
      } else {
        _favoriteProducts.add(product);
      }
    });
  }


// Метод поля поиска
  Future<List<dynamic>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('https://uvlfpiijmtcpjdunxiwg.supabase.co/rest/v1/products?select=*name&name=ilike.$query*'), // косяк
      headers: {
        'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV2bGZwaWlqbXRjcGpkdW54aXdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTM4OTY1MzMsImV4cCI6MjAyOTQ3MjUzM30.xlpxQBJhQhBHBoHeke-hE7CRamMYNmHXGz1dudDp25I',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Ничего не нашёл :(');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Справочник продуктов'),
          backgroundColor: Colors.lightGreen, // Устанавливаем цвет фона шапки верхней части
          elevation: 5,
          actions: [        // правая часть шапки
            IconButton(
              icon: Icon(Icons.star_rounded),  /// иконка избранного
              onPressed: () {  // при нажатии открывает страница избранного
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesScreen(favoriteProducts: _favoriteProducts, toggleFavorite: toggleFavorite),
                  ),
                );
              },
            ),
          ],
        ),
        body:       // тело проги
        Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Поиск продуктов',     // в поле поиска
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {   // Callback-функция, вызываемая при изменении текста в поле ввода.
                  if (value.isNotEmpty) {
                    setState(() {   // храним состояние - вызываем метод
                      _productsFuture = searchProducts(value);
                    });
                  } else {
                    setState(() {
                      _productsFuture = fetchProducts();
                    });
                  }
                },
              ),
              Expanded(
                child:
                FutureBuilder<List<dynamic>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Ошибка: ${snapshot.error}'));
                    } else {
                      final products = snapshot.data!;
                      return CategoryListScreen(products: products, toggleFavorite: toggleFavorite, favoriteProducts: _favoriteProducts);
                    }
                  },
                ),
              )])); // кто за чё отвечает =>
  }
}