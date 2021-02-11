import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/custom_route.dart';
import '../providers/auth.dart';
import '../screens/user_products.dart';
import '../screens/orders.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key key}) : super(key: key);
  Widget buildListTileDrawer(
      IconData icon, String title, Function function, BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: function,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: [
        AppBar(
          title: Text('Shoppingy'),
          automaticallyImplyLeading: false,
        ),
        Divider(),
        buildListTileDrawer(Icons.shop, 'Shop', () {
          Navigator.of(context).pushReplacementNamed('/');
        }, context),
        buildListTileDrawer(Icons.payment, 'Orders', () {
          Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
          /*  Navigator.of(context).pushReplacement(
            CustomRoute(builder: (ctx) => OrdersScreen()),
          ); */
        }, context),
        buildListTileDrawer(Icons.edit, 'Manage Products', () {
          Navigator.of(context)
              .pushReplacementNamed(UserProductsScreen.routeName);
        }, context),
        //    Divider(),

        buildListTileDrawer(Icons.exit_to_app, 'Logout', () {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed('/');

          Provider.of<Auth>(context, listen: false).logout();
        }, context)
      ],
    ));
  }
}
