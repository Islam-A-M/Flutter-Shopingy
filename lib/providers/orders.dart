import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../models/http_exception.dart';
import '../providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;
  Orders(this.authToken, this.userId, this._orders);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    try {
      final url =
          'https://flutter-260e7.firebaseio.com/orders/$userId.json?auth=$authToken';

      var cartProductsData = cartProducts
          .map((cartProduct) => {
                'price': cartProduct.price,
                'quantity': cartProduct.quantity,
                'id': cartProduct.id,
                'title': cartProduct.title,
              })
          .toList();
      //var cartProductsData = jsonEncode(cartProducts.toList());
      final timestamp = DateTime.now();
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'products': cartProductsData,
            'dateTime': timestamp.toIso8601String()
          }));
      if (response.statusCode >= 400) {
        throw HttpException('An error occurred!');
      }
      _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: timestamp),
      );
      notifyListeners();
    } catch (e) {
      print(e);
      throw HttpException('An error occurred!');
    }
  }

  Future<void> fetchAndSetOrders() async {
    if (authToken == null) {
      throw "AuthError";
    }
    final url =
        'https://flutter-260e7.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      final response = await http.get(url);
      print(response.body);
      // final extractedData = json.decode(response.body) as Map<String, dynamic>;

      final extractedData = json.decode(response.body) as Map<String, Object>;
      final List<OrderItem> loadedOrders = [];
      print('response.statusCode');
      print(response.statusCode);

      if (response.statusCode >= 400) {
        HttpException("An Error occurred");
      }
      if (extractedData == null) {
        return;
      }

      extractedData.forEach((orderId, orderData) {
        final ordData = jsonDecode(json.encode(orderData));
        var cartProductsData = (ordData['products'] as List<dynamic>)
            .map((cartProduct) => CartItem(
                id: cartProduct['id'],
                title: cartProduct['title'],
                quantity: cartProduct['quantity'],
                price: cartProduct['price']))
            .toList();

        loadedOrders.add(OrderItem(
            id: orderId,
            amount: ordData['amount'].toDouble(),
            dateTime: DateTime.parse(ordData['dateTime']),
            products: cartProductsData));
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      print('e');
      print(e);

      throw HttpException(e);
      print(e);
      // throw e;
    }
  }
}
