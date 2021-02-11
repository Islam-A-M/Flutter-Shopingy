import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../widgets/snackbar.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;
  // final double price;

  // const ProductItem(this.id, this.title, this.imageUrl, this.price);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Product>(context, listen: false);
    //final productsContainer = Provider.of<Products>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    print("buildd");
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GridTile(
              child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      ProductDetailScreen.routeName,
                      arguments: productData.id,
                    );
                  },
                  child: Hero(
                    tag: productData.id,
                    child: FadeInImage(
                      placeholder:
                          AssetImage('assets/images/product-placeholder.png'),
                      imageErrorBuilder: (ctx, obj, stacktrace) => Image.asset(
                        'assets/images/product-placeholder12.png',
                        fit: BoxFit.cover,
                      ),
                      image: NetworkImage(productData.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ) /* Image.network(
                  productData.imageUrl,
                  fit: BoxFit.cover,
                ), */
                  ),
              header: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    // margin: const EdgeInsets.only(left: 10),
                    children: [
                      Chip(
                        backgroundColor: Colors.blueGrey,
                        label: Text(
                          '${productData.price} \$',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                    alignment: Alignment.topLeft,
                    //decoration: BoxDecoration(
                    //  border: Border.all(color: Colors.black45),
                    //color: Colors.black26,
                  ),
                ],
              ),
              footer: GridTileBar(
                //leading:

                backgroundColor: Colors.black54,
                title: Text(
                  productData.title,
                  textAlign: TextAlign.center,
                ),
                //trailing:
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Consumer<Product>(
                  builder: (ctx, productData, child) => IconButton(
                        icon: Icon(productData.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border),
                        onPressed: () async {
                          try {
                            await productData.toggleFavoriteStatus(
                                authData.token, authData.userId);
                          } catch (e) {
                            Scaffold.of(context).showSnackBar(CustomSnackBar(
                              e.toString(),
                              Icon(Icons.error, color: Colors.white),
                              null,
                            ));
                          }
                          //productsContainer.notifyListener();
                        },
                      )),

              // LinearGradient(begin: Alignment.center),

              Container(
                width: 2,
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),
                ),
              ),

              IconButton(
                icon: Icon(Icons.shopping_cart),
                color: Colors.black,
                onPressed: () {
                  cart.addItem(
                      productData.id, productData.price, productData.title);
                  Scaffold.of(context).hideCurrentSnackBar();

                  Scaffold.of(context).showSnackBar(CustomSnackBar(
                    'Added item to cart',
                    Icon(Icons.done, color: Colors.white),
                    SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cart.removeSingleItem(productData.id);
                      },
                      textColor: Colors.white,
                    ),
                  ));
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
