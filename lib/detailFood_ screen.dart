
// страница продукта ( с состоянием )
import 'package:flutter/material.dart';

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
