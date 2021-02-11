import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../providers/cart.dart' as cProvider;

import 'package:provider/provider.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;

  final double price;
  final int quantity;
  final String title;
  Widget dismissibleItems(Color color, IconData icon, Alignment alignment,
      EdgeInsets edgeInsets, Function function) {
    return Expanded(
      child: GestureDetector(
        onTap: function,
        // margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            margin: edgeInsets,
            color: color,
            child: Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
            alignment: alignment,
            // padding: EdgeInsets.only(right: 20),
            //margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          ),
        ),
      ),
    );
  }

  const CartItem(
      this.id, this.productId, this.price, this.quantity, this.title);
  @override
  Widget build(BuildContext context) {
    Timer timer;
    var c = new Completer(); // declare a completer.

    Future waitUserAction() async {
      c = new Completer();
      const oneSec = const Duration(seconds: 3);

      timer = new Timer.periodic(oneSec, (Timer timer) {
        timer.cancel();
        if (c.isCompleted) {
          return;
        }
        c.complete(false);
      });

      return c.future;
    }

    return Container(
      child: Dismissible(
        confirmDismiss: (DismissDirection direction) async {
          return await waitUserAction();
          //   if (direction == DismissDirection.startToEnd) {
/*             print(quantity);
 */
          /*    Provider.of<cProvider.CartItem>(context, listen: false)
                .removeOneItem(); */
          /* 
                     Provider.of<cProvider.Cart>(context, listen: false)
                .notifyCartListeners();
                 */
/* 
          if (quantity < 1) {
            return true;
          } else {
            return false;
          } */

          //    }
        },
        //direction: DismissDirection.endToStart,

        onDismissed: (direction) {
          print(direction);
        },
        //  dragStartBehavior: DragStartBehavior.down,
        background: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            dismissibleItems(Colors.green, Icons.exposure_minus_1,
                Alignment.centerLeft, const EdgeInsets.only(left: 16), () {
              timer.cancel();
              c.complete(false);
              Provider.of<cProvider.Cart>(context, listen: false)
                  .removeSingleItem(productId);
              return false;
            }),
            dismissibleItems(Theme.of(context).errorColor, Icons.delete,
                Alignment.centerRight, const EdgeInsets.only(right: 16), () {
              timer.cancel();
              c.complete(false);

              return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    elevation: 6,
                    title: const Text("Confirm"),
                    content: const Text(
                        "Are you sure you wish to delete this item?"),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () {
                            Provider.of<cProvider.Cart>(context, listen: false)
                                .removeItem(productId);
                            return Navigator.of(context).pop(true);
                          },
                          child: const Text("DELETE")),
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("CANCEL"),
                      ),
                    ],
                  );
                },
              );
            }),
          ],
        ),
        key: ValueKey(id),
        child: Card(
          elevation: 1,
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          child: Padding(
            padding: EdgeInsets.only(right: 1),
            child: ListTile(
              //  dense: true,
              leading: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: Container(
                  width: 80,
                  margin: EdgeInsets.only(right: 10),
                  child: Text('\$$price',
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 17,
                        //color: Colors.white,
                        //backgroundColor: Colors.blue,
                      )),
                ),
              ),
              title: Text(title),
              subtitle: Text('Total: \$${(price * quantity)}'),
              trailing: Text('$quantity x'),
            ),
          ),
        ),
      ),
    );
  }
}
