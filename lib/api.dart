import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'models/book_list.dart';
import 'package:library_frontend/models/books_scanned.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class API {
  API(this.context);

  final BuildContext context;

  GlobalConfiguration cfg = GlobalConfiguration();

  getBookByID(String msg) async {
    var content = '{"id":${int.parse(msg)}}';
    var url = Uri.parse("${cfg.get("host")}/get/id");

    var res = await http.post(url, body: content);
    print("res for get bookByID is  ${res.body}");

    if(res.body.contains("sql: no rows in result set")) {
      print("books does not exist");
      return;
    }

    Map dr = jsonDecode(res.body);
    if(dr["available"]) {
      context.read<BooksScanned>().add(dr);
    }
    return dr;
  }

  getByTitle(String query) async {
    if (query == "") {
      getAllBooks();
      return;
    }

    String content = '{"query":"$query"}';
    var url = Uri.parse("${cfg.get("host")}/search/title");

    var res = await http.post(url, body: content);
    print("length of search by title  ${res.body.length}");
    print(res.body);
    var dcdc = jsonDecode(res.body);
    context.read<BookList>().clear();
    if (dcdc != null) {
      context.read<BookList>().add(dcdc);
    }
  }

  getAllBooks() async {
    var url = Uri.parse("${cfg.get("host")}/get");

    var res = await http.post(url, body: '');
    print("length of get all books  ${res.body.length}");

    var dcdc = jsonDecode(res.body);
    print(dcdc[10]);
    context.read<BookList>().clear();
    context.read<BookList>().add(dcdc);
  }

  updateBooks(String name) async {
    var books = context.read<BooksScanned>().books;

    List ids = [];
    for(var i=0; i<books.length; i++) {
      ids.add(books[i]["id"]);
    }

    String content = '{"ids":$ids, "available":false, "name":"${_parseWord(name)}"}';
    var url = Uri.parse("${cfg.get("host")}/update");

    var res = await http.post(url, body: content);
    print("updating books was a ${res.body}");
    context.read<BooksScanned>().clear();

    getAllBooks();
  }

  Future<int> addBook(String title, String author) async {
    String content = '{"title":"${_parseWord(title)}", "author":"${_parseWord(author)}"}';
    print('host is: ${cfg.get("host")}');
    var url = Uri.parse("${cfg.get("host")}/new");
    print('url is: $url');

    var res = await http.post(url, body: content);
    print("res for add book is: ${res.body}");
    getAllBooks();
    return int.parse(res.body);
  }

  deleteBook(int id) async {
    String content = '{"id":$id}';
    var url = Uri.parse("${cfg.get("host")}/delete");
    print('url is: $url');

    var res = await http.post(url, body: content);
    print("res for delete book is: ${res.body}");
    getAllBooks();
  }

  returnBook(int id) async {
    String content = '{"available":true, "id":$id}';
    var url = Uri.parse("${cfg.get("host")}/checkout");
    print('url is: $url');

    var res = await http.post(url, body: content);
    print("res for return book is: ${res.body}");
    getAllBooks();
  }

  String _parseWord(String txt) {
    String newTxt="";
    List<String> badWords = ["or", "are", "on", "a", "the", "in"];

    List<String> words = txt.trim().split(" ");
    for(var i=0; i<words.length; i++) {
      if (i == 0) {
        newTxt = words[i][0].toUpperCase() + words[i].substring(1);
      } else {
        bool bad = false;
        for(var j=0; j<badWords.length; j++) {
          print(j);
          if (words[i].toLowerCase() == badWords[j]) {
            bad = true;
          }
        }
        if(!bad) {
          print("word is ${words[i]}");
          words[i] = words[i][0].toUpperCase() + words[i].substring(1);
        }
        newTxt ='$newTxt ${words[i]}';
      }
    }

    return newTxt;
  }
}

