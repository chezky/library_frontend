import 'package:flutter/material.dart';

class Account extends ChangeNotifier {
  Map _account = {};

  Map get account => _account;

  void set(a) {
    _account = a;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void clear() {
    _account = {};
    notifyListeners();
  }

  int bookCount() {
    if(_account.isNotEmpty) {
      return _account["book_count"];
    }
    return 0;
  }
}