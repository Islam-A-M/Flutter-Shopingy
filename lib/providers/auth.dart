import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoppingy/helpers/keys.dart';
import 'package:shoppingy/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  final keyv = encrypt.Key.fromUtf8('poses()@#)(2sad221!@#!@8677dwwq!');
  final iv = encrypt.IV.fromLength(16);

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  static const webKey = 'AIzaSyCtWZP78f5v7e-ZEigwqdrOR_tvRt2s5j4';
  Future<void> _authenticate(
      String urlSegment, String email, String password) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$webKey';

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      if (response.statusCode >= 400) {
        print(response.body);

        throw HttpException('An Error occurred!');
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(seconds: int.parse(responseData['expiresIn'])),
      );
      _autoLogout();
      notifyListeners();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final encrypter = encrypt.Encrypter(encrypt.AES(keyv));

      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      final encrypted = encrypter.encrypt(userData, iv: iv);

      prefs.setString('userData', encrypted.base64);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> signup(String email, String password) async {
    const urlSegment = 'signUp';
    return _authenticate(urlSegment, email, password);
  }

  Future<void> signin(String email, String password) async {
    const urlSegment = 'signInWithPassword';

    return _authenticate(urlSegment, email, password);
  }

  Future<bool> tryAutoSignin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedEncryptedUserData = prefs.getString('userData');
    final encrypter = encrypt.Encrypter(encrypt.AES(keyv));
    //print("extractedEncryptedUserData");
    //print(extractedEncryptedUserData);
    final decryptedUserData = encrypter
        .decrypt(encrypt.Encrypted.from64(extractedEncryptedUserData), iv: iv);

    final extractedUserData =
        json.decode(decryptedUserData) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    Keys.navKey.currentState.pushReplacementNamed('/');

    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
