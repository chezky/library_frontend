import 'package:flutter/material.dart';

class BooksScanned extends ChangeNotifier {
  List<Map> _books = [];

  List<Map> get books => _books;

  void add(Map b) {
    for(var i=0; i<books.length; i++){
      if (books[i]["id"] == b["id"]) {
        print("books already in list");
        return;
      }
    }

    _books.add(b);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void remove(int i) {
    _books.removeAt(i);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void clear() {
    _books.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}