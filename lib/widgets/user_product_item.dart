import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../screens/edit_product.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  final Function deleteHandler;

  const UserProductItem(
      {Key key, this.id, this.title, this.imageUrl, this.deleteHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading:
          /* CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ) */
          Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
        ),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  EditProductScreen.routeNamee,
                  arguments: id,
                );
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              /*       
              splashColor: Colors.transparent,
              highlightColor: Colors.black12,
              enableFeedback: false, */
              icon: Icon(Icons.delete),
              onPressed: () {
                //  Provider.of<Products>(context, listen: false).deleteProduct(id);
                deleteHandler();
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
