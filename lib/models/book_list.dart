import 'package:flutter/material.dart';

class BookList extends ChangeNotifier {
  List _books = [];

  List get books => _books;

  void add(b) {
    _books.addAll(b);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void remove(b) {
    _books.remove(b);
    notifyListeners();
  }

  void clear() {
    _books.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}