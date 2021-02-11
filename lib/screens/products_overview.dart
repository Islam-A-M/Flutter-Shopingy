import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/snackbar.dart';
import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../screens/cart.dart';
import '../providers/cart.dart';
import '../widgets/product_grid.dart';
import '../widgets/badge.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = false;
  var _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    // TODO: implement initState
    //Provider.of<Products>(context, listen: false).fetchAndSetProducts();
/*     Future.delayed(Duration.zero).then((value) {
      Provider.of<Products>(context, listen: false).fetchAndSetProducts();
    }); */
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context, listen: true)
          .fetchAndSetProducts()
          .catchError((_) {
        _scaffoldKey.currentState.showSnackBar(
            CustomSnackBar('An Error occurred', Icon(Icons.error), null));
      }).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      _isInit = true;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final productsContainer = Provider.of<Products>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Shoppingy'),
        actions: [
          PopupMenuButton(
            padding: EdgeInsets.all(1),
            shape: Border.all(),
            onSelected: (FilterOptions selectedValue) {
              print(selectedValue);
              setState(() {
                if (selectedValue == FilterOptions.All) {
                  //   productsContainer.showAll();

                  _showOnlyFavorites = false;
                } else {
                  _showOnlyFavorites = true;

                  //    productsContainer.showFavoritesOnly();
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorits'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
            icon: Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (_, cartData, child) => Badge(
              child: child,
              value: cartData.itemCount.toString(),
              color: Colors.red,
            ),
            child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                }),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductGrid(
              showFavorites: _showOnlyFavorites,
            ),
    );
  }
}
