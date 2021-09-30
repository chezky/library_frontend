import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:library_frontend/models/accounts_list.dart';
import 'models/account.dart';
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
    var url = Uri.parse("${cfg.get("host")}/book/get/id");

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
    var url = Uri.parse("${cfg.get("host")}/book/search");

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
    var url = Uri.parse("${cfg.get("host")}/book/get");

    var res = await http.post(url, body: '');
    print("length of get all books  ${res.body.length}");

    var dcdc = jsonDecode(res.body);
    context.read<BookList>().clear();
    context.read<BookList>().add(dcdc);
  }

  Future<String> updateBooks() async {
    var books = context.read<BooksScanned>().books;

    List ids = [];
    for(var i=0; i<books.length; i++) {
      ids.add(books[i]["id"]);
    }

    String content = '{"ids":$ids, "customer_id":${context.read<Account>().account["id"]}}';
    var url = Uri.parse("${cfg.get("host")}/book/update");

    var res = await http.post(url, body: content);
    print("updating books was a ${res.body}");
    context.read<BooksScanned>().clear();
    getAllBooks();
    getAllAccounts();
    return res.body.toString();
  }

  Future<int> addBook(String title, String author) async {
    String content = '{"title":"${parseWord(title)}", "author":"${parseWord(author)}"}';
    print('host is: ${cfg.get("host")}');
    var url = Uri.parse("${cfg.get("host")}/book/new");
    print('url is: $url');

    var res = await http.post(url, body: content);
    print("res for add book is: ${res.body}");
    getAllBooks();
    return int.parse(res.body);
  }

  deleteBook(int id) async {
    String content = '{"id":$id}';
    var url = Uri.parse("${cfg.get("host")}/book/delete");
    print('url is: $url');

    var res = await http.post(url, body: content);
    print("res for delete book is: ${res.body}");
    getAllBooks();
  }

  Future<String> returnBook(int id) async {
    String content = '{"available":true, "id":$id}';
    var url = Uri.parse("${cfg.get("host")}/book/checkout");
    print('url is: $url');

    var res = await http.post(url, body: content);
    print("res for return book is: ${res.body}");
    getAllBooks();
    getAllAccounts();
    return res.body.toString();
  }

  // api for accounts
  getAllAccounts() async {
    var url = Uri.parse("${cfg.get("host")}/account/get");

    var res = await http.post(url, body: '');
    print("length of get all accounts  ${res.body.length}");

    var dcdc = jsonDecode(res.body);
    print(dcdc);
    context.read<AccountsList>().clear();
    if (dcdc != null) {
      context.read<AccountsList>().add(dcdc);
    }
  }

  Future getAccountByID(int id) async {
    var url = Uri.parse("${cfg.get("host")}/account/get/id");

    String content = '{"id":$id}';
    var res = await http.post(url, body: content);
    print("length of get get account by id is:  ${res.body.length}");
    print("result of get acccount by id: ${res.body}");

    var dcdc = jsonDecode(res.body);
    // context.read<Account>().set(dcdc);
    if (dcdc != null) {
      return dcdc;
    }
    return "error";
  }

  Future<String> updateAccount(int id, String name, email, bool emailList) async {
    var url = Uri.parse("${cfg.get("host")}/account/update");

    String content = '{"id":$id, "name": "$name", "email":"$email","email_list":$emailList}';
    print(content);
    var res = await http.post(url, body: content);
    print("length of update account is:  ${res.body.length}");
    print("result of update account: ${res.body}");
    getAllAccounts();
    if (res.body != null) {
      return res.body.toString();
    }
    return "error";
  }


  searchAccounts(String query) async {
    if (query == "") {
      getAllAccounts();
      return;
    }

    String content = '{"query":"$query"}';
    var url = Uri.parse("${cfg.get("host")}/account/search");

    var res = await http.post(url, body: content);
    print("length of search accounts  ${res.body.length}");
    print(res.body);
    var dcdc = jsonDecode(res.body);
    context.read<AccountsList>().clear();
    if (dcdc != null) {
      context.read<AccountsList>().add(dcdc);
    }
  }

  Future<int> addAccount(String name, email) async {
    String content = '{"name":"${parseWord(name)}", "email":"$email"}';
    var url = Uri.parse("${cfg.get("host")}/account/new");
    print('url is: $url');

    var res = await http.post(url, body: content);
    print("res for add account is: ${res.body}");
    getAllAccounts();
    return int.parse(res.body);
  }


  void deleteAccount(int id) async {
    String content = '{"id":$id}';
    var url = Uri.parse("${cfg.get("host")}/account/delete");
    print('url is: $url');

    var res = await http.post(url, body: content);
    print("res for delete account is: ${res.body}");
    getAllAccounts();
  }


  String parseWord(String txt) {
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

