import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppingy/screens/auth_screen.dart';

import '../widgets/snackbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';
  OrdersScreen({Key key}) : super(key: key);

/*   @override
  _OrdersScreenState createState() => _OrdersScreenState();
} */

//class _OrdersScreenState extends State<OrdersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
/*   Future _ordersFuture;
  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  } */

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapshot.error != null) {
                print('dataSnapshot.error');
                if (dataSnapshot.error == 'AuthError') {
                  /*            Future.delayed(Duration.zero).then((value) =>
                      Navigator.of(context).pushReplacementNamed('/')); */
                  return Container();
                }
                print(dataSnapshot.error);
                _scaffoldKey.currentState.removeCurrentSnackBar();
                _scaffoldKey.currentState.showSnackBar(CustomSnackBar(
                    'An Error occurred', Icon(Icons.error), null));
                return Container();
              } else {
                return Consumer<Orders>(
                  builder: (ctx, orderData, child) => RefreshIndicator(
                    onRefresh: () async {
                      try {
                        await Provider.of<Orders>(context, listen: false)
                            .fetchAndSetOrders();
                      } catch (e) {
                        _scaffoldKey.currentState.removeCurrentSnackBar();
                        _scaffoldKey.currentState.showSnackBar(CustomSnackBar(
                            'An Error occurred', Icon(Icons.error), null));
                      }
                    },
                    child: Stack(
                      children: [
                        ListView.builder(
                          itemBuilder: (ctx, i) =>
                              OrderItem(orderData.orders[i]),
                          itemCount: orderData.orders.length,
                        ),
                        if (orderData.orders.length == 0) child,
                      ],
                    ),
                  ),
                  child:
                      const Center(child: const Text('There is no orders yet')),
                );
              }
            }
            return Container();
          },
        ));
  }
}
