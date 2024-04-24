import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Справочник продуктов',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<dynamic>> _productsFuture;
  List<dynamic> _favoriteProducts = [];
  final TextEditingController _searchController = TextEditingController(); // для Поийска

  @override
  void initState() {
    super.initState();
    _productsFuture = fetchProducts();
  }

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
      throw Exception('Failed to fetch products');
    }
  }

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
      Uri.parse('https://uvlfpiijmtcpjdunxiwg.supabase.co/rest/v1/products?select=*name&name=ilike.$query*'),
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
          actions: [
            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
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
        body:
        Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Поиск продуктов',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _productsFuture = searchProducts(value);
                    });
                  } else {
                    setState(() {
                      _productsFuture = fetchProducts();
                    });
                  }
                },
              ),
              Expanded(  child: FutureBuilder<List<dynamic>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final products = snapshot.data!;
                    return CategoryListScreen(products: products, toggleFavorite: toggleFavorite, favoriteProducts: _favoriteProducts);
                  }
                },
              ),
              )]));
  }
}

class CategoryListScreen extends StatelessWidget {
  final List<dynamic> products;
  final Function(dynamic) toggleFavorite;
  final List<dynamic> favoriteProducts;

  CategoryListScreen({required this.products, required this.toggleFavorite, required this.favoriteProducts});

  @override
  Widget build(BuildContext context) {
    Map<String, List<dynamic>> groupedProducts = {};
    products.forEach((product) {
      final category = product['category'];
      if (!groupedProducts.containsKey(category)) {
        groupedProducts[category] = [];
      }
      groupedProducts[category]!.add(product);
    });

    return Scaffold(
      body: ListView.builder(
        itemCount: groupedProducts.length,
        itemBuilder: (context, index) {
          final category = groupedProducts.keys.elementAt(index);
          final categoryProducts = groupedProducts[category]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: categoryProducts.length,
                itemBuilder: (context, index) {
                  final product = categoryProducts[index];
                  final isFavorite = favoriteProducts.contains(product);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: product, isFavorite: isFavorite, toggleFavorite: toggleFavorite),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(
                              product['image_url'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              product['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

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
      body: ListView.builder(
        itemCount: favoriteProducts.length,
        itemBuilder: (context, index) {
          final product = favoriteProducts[index];
          return ListTile(
            leading: Image.network(product['image_url']),
            title: Text(product['name']),
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

class ProductDetailScreen extends StatefulWidget {
  final dynamic product;
  final bool isFavorite;
  final Function(dynamic) toggleFavorite;

  ProductDetailScreen({required this.product, required this.isFavorite, required this.toggleFavorite});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['name']),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              widget.toggleFavorite(widget.product);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(widget.product['image_url']),
            SizedBox(height: 20),
            Text('Каллории: ${widget.product['calories']}'),
            Text('Питательная ценность: ${widget.product['nutrients']}'),
            Text('Ингредиенты: ${widget.product['ingredients']}'),
            Text('Противопоказания: ${widget.product['warnings']}'),
          ],
        ),
      ),
    );
  }
}