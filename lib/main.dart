import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ProductListScreen(),
    );
  }
}




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
}   // Конец главного экрана





// разделяем продукты на категории (тоже созданы в бд supabase)
class CategoryListScreen extends StatelessWidget {
  final List<dynamic> products;
  final Function(dynamic) toggleFavorite;
  final List<dynamic> favoriteProducts;

  CategoryListScreen({required this.products, required this.toggleFavorite, required this.favoriteProducts});

  @override
  Widget build(BuildContext context) {
    Map<String, List<dynamic>> groupedProducts = {};
    products.forEach((product) {
      final category = product['category'];   // из таблицы бд
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
                padding: const EdgeInsets.all(22.0), // box категории
                child: Text(
                  category,
                  style: TextStyle(     // стиль текста категорий
                    fontSize: 26,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              GridView.builder(  // строим сетку для продуктов
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,    // кол-во в ряд
                  childAspectRatio: 1,     // размер одного
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
                      elevation: 0.3,  // тень
                      color: Colors.white,
                      shape: RoundedRectangleBorder(  // округление рамки
                        borderRadius: BorderRadius.circular(35.0),
                      ),
                      shadowColor: Colors.lightGreen,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(             // фотку не забываем
                              product['image_url'],           // ссылка с таблицы бд
                              fit: BoxFit.fitHeight, // размер картинки
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              product['name'],      // ну и назыввание
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w300),
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






// Экран избранного
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





// страница продукта ( с состоянием )
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
        backgroundColor: Colors.lightGreen,
        elevation: 5,
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),   // какая иконка избраннного будет отображаться
            onPressed: () {     // при нажатии
              setState(() {
                _isFavorite = !_isFavorite;
              });
              widget.toggleFavorite(widget.product);
            },
          ),
        ],
      ),
      // ТЕЛО
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              widget.product['image_url'],
              fit: BoxFit.contain,
              height: 200.0,
            ),
            Card(
              elevation: 1,
              color: Colors.white,
              margin: EdgeInsets.only(bottom: 20.0),
              shadowColor: Colors.black,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height:10,),
                        Text(
                          widget.product['name'],
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic
                          ),
                        ),
                        SizedBox(
                          width: 100,   // ширина виджета
                          height: 70,   // высота виджета
                          child: Text(widget.product['category']), // дочерний виджет внутри SizedBox
                        ),



                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                            Icon(Icons.accessibility_new_rounded),
                            Text(
                          ' Калории:   ${widget.product['calories']}',
                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
                        ),],),
                        SizedBox(height:10),
                        Row(
                          children: [
                            Icon(Icons.add,),
                            Expanded(child:
                        Text(
                          ' Пит.ценность:${widget.product['nutrients']}',
                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
                        ),
                            ), ],),
                        SizedBox(height:10),
                            Row(
                              children: [
                                Icon(Icons.favorite_border,),
                                Expanded(child:
                        Text(
                          ' Ингредиенты: ${widget.product['ingredients']}',
                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
                        ),),],),
                        SizedBox(height:10),
                    Row(
                      children: [
                        Icon(Icons.dangerous_outlined,),
                        Expanded(child:
                        Text(
                          'Противопоказания: ${widget.product['warnings']}',
                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
                        ),
                        ),], ),  ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),


    );
  }
}
