import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/snackbar.dart';
import '../screens/edit_product.dart';
import '../widgets/user_product_item.dart';
import '../providers/products.dart';
import '../widgets/app_drawer.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';
  Future<void> _refreshProducts(
      BuildContext context, GlobalKey<ScaffoldState> _scaffoldKey) async {
    try {
      await Provider.of<Products>(context, listen: false)
          .fetchAndSetProducts(true);
    } catch (e) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
          CustomSnackBar('An Error occurred', Icon(Icons.error), null));
    }
  }

  @override
  Widget build(BuildContext context) {
    // final productData = Provider.of<Products>(context);
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeNamee);
              //.. navigate to add screen
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context, _scaffoldKey),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context, _scaffoldKey),
                    //notificationPredicate: ,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Consumer<Products>(
                        builder: (_, productData, child) => ListView.builder(
                          itemBuilder: (_, i) => Column(
                            children: [
                              UserProductItem(
                                id: productData.items[i].id,
                                title: productData.items[i].title,
                                imageUrl: productData.items[i].imageUrl,
                                deleteHandler: () async {
                                  try {
                                    await productData
                                        .deleteProduct(productData.items[i].id);
                                  } catch (e) {
                                    _scaffoldKey.currentState
                                        .showSnackBar(CustomSnackBar(
                                      'Deleting Failed',
                                      Icon(Icons.error, color: Colors.white),
                                      null,
                                    ));
                                    /*   Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text('Deleting failed!')));
                         */
                                  }
                                },
                              ),
                              Divider()
                            ],
                          ),
                          itemCount: productData.items.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
