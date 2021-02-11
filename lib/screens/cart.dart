import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/snackbar.dart';
import '../providers/orders.dart';
import '../widgets/cart_item.dart';
import '../providers/cart.dart' show Cart;

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  const CartScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();

    final cart = Provider.of<Cart>(context);
    print("cartBuild");
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Cart'),
        ),
        body: Column(
          children: [
            Card(
              margin: EdgeInsets.all(15),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 20),
                    ),
                    /* SizedBox(
                      width: 10,
                    ), */
                    Spacer(),
                    Chip(
                      label: Text(
                        '\$${cart.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .headline6
                                .color),
                      ),
                      backgroundColor: Theme.of(context).accentColor,
                    ),
                    OrderButton(cart: cart, scaffoldKey: _scaffoldKey)
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
                child: ListView.builder(
              itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                  //create: (ctx) => products[i],
                  value: cart.items.values.toList()[i],
                  child: CartItem(
                      cart.items.values.toList()[i].id,
                      cart.items.keys.toList()[i],
                      cart.items.values.toList()[i].price,
                      cart.items.values.toList()[i].quantity,
                      cart.items.values.toList()[i].title)),
              itemCount: cart.items.length,
            ))
          ],
        ));
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
    @required GlobalKey<ScaffoldState> scaffoldKey,
  })  : _scaffoldKey = scaffoldKey,
        super(key: key);

  final Cart cart;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () async {
        if (widget.cart.items.values.length == 0 || _isLoading) {
          widget._scaffoldKey.currentState.removeCurrentSnackBar();
          widget._scaffoldKey.currentState.showSnackBar(CustomSnackBar(
            'Cart has no items to make order',
            Icon(Icons.error, color: Colors.white),
            null,
          ));
          return;
        }
        setState(() {
          _isLoading = true;
        });
        try {
          await Provider.of<Orders>(context, listen: false).addOrder(
            widget.cart.items.values.toList(),
            widget.cart.totalAmount,
          );
          widget.cart.clearCart();
          setState(() {
            _isLoading = false;
          });
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          widget._scaffoldKey.currentState.showSnackBar(CustomSnackBar(
            e.toString(),
            Icon(Icons.error, color: Colors.white),
            null,
          ));
        }
      },
      child: _isLoading
          ? CircularProgressIndicator()
          : Text(
              'ORDER NOW',
              style: TextStyle(),
            ),
      textColor: widget.cart.items.values.length == 0
          ? Colors.grey
          : Theme.of(context).primaryColor,
    );
  }
}
