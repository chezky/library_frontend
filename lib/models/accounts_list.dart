import 'package:flutter/material.dart';

class AccountsList extends ChangeNotifier {
  List _accounts = [];

  List get accounts => _accounts;

  void add(b) {
    _accounts.addAll(b);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void remove(b) {
    _accounts.remove(b);
    notifyListeners();
  }

  void clear() {
    _accounts.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}