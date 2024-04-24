
// разделяем продукты на категории (тоже созданы в бд supabase)
import 'package:flutter/material.dart';
import 'package:foodzone/detailFood_%20screen.dart';
import 'package:foodzone/main.dart';

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


