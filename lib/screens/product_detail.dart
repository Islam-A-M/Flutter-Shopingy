import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  // const ProductDetailScreen(this.title);
  Widget lineWidget() {
    return Container(
      width: double.infinity,
      height: 2,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 0.1,
          ),
        ),
      ),
    );
  }

  static const String routeName = '/product-detail';
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: true).findById(productId);

    return Scaffold(
      /*   appBar: AppBar(
        title: Text(loadedProduct.title),
      ), */
      body:
          /* SingleChildScrollView(child:   child: Column(
          children: [
            Container(
                //color: Colors.red,
                height: 300,
                width: double.infinity,
                child: Hero(
                  tag: loadedProduct.id,
                  child: FadeInImage(
                    placeholder:
                        AssetImage('assets/images/product-placeholder.png'),
                    image: NetworkImage(loadedProduct.imageUrl),
                    fit: BoxFit.fill,
                    placeholderErrorBuilder: (ctx, obj, stackTrace) =>
                        Image.asset(
                      'assets/images/product-placeholder12.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ) /*  Image.network(
                loadedProduct.imageUrl,
                fit: BoxFit.fill,
              ), */
                ),
            SizedBox(height: 10),
            lineWidget(),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  child: Text(
                    '${loadedProduct.price}\$',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    'Price:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            lineWidget(),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                loadedProduct.description,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ],
        ),
 ,) */
          CustomScrollView(
        slivers: [
          SliverAppBar(
            forceElevated: true,
            shape: BeveledRectangleBorder(
              side: BorderSide.lerp(BorderSide(color: Colors.green),
                  BorderSide(color: Colors.grey), 1),
              borderRadius: BorderRadius.all(Radius.elliptical(3, 3)),
            ),
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: loadedProduct.id,
                child: FadeInImage(
                  placeholder:
                      AssetImage('assets/images/product-placeholder.png'),
                  image: NetworkImage(loadedProduct.imageUrl),
                  fit: BoxFit.fill,
                  placeholderErrorBuilder: (ctx, obj, stackTrace) =>
                      Image.asset(
                    'assets/images/product-placeholder12.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 10),
              lineWidget(),
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    child: Text(
                      '${loadedProduct.price}\$',
                      style: TextStyle(
                        /*  shadows: [
                          Shadow(
                              color: Colors.grey,
                              blurRadius: 0,
                              offset: Offset(0, 20))
                        ], */

                        color: Colors.black87,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    width: double.infinity,
                    child: Text(
                      'Price:',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              lineWidget(),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  loadedProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              SizedBox(
                height: 800,
              )
            ]),
          ),
        ],
      ),
    );
  }
}
