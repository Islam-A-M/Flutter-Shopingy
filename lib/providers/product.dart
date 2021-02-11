import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shoppingy/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });
  Future<void> toggleFavoriteStatus(String authToken, String userId) async {
    try {
      isFavorite = !isFavorite;
      notifyListeners();

      final url =
          'https://flutter-260e7.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';

      final response = await http.put(url,
          body: json.encode(
            isFavorite,
          ));
      if (response.statusCode >= 400) {
        throw HttpException('An error occurred!');
      }
    } catch (e) {
      isFavorite = !isFavorite;
      notifyListeners();

      throw HttpException('An error occurred');
    }
  }
}
