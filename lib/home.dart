import 'package:flutter/material.dart';
import 'package:library_frontend/api.dart';
import 'package:library_frontend/list.dart';
import 'models/book_list.dart';
import 'package:library_frontend/update.dart';
import 'package:library_frontend/new_book.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Widget _topIcons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10,20,10,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            color: Colors.grey,
            onPressed: () => {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddBookPage()))
            },
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0,0,0,0),
      child: const Text(
          'AyalaBrary',
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w200,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _infoPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0,0,0,0),
      child: Consumer<BookList>(
        builder: (BuildContext context, BookList bl, dynamic c) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _infoContainer("Checked Out", "${bl.books.where((e) => e["available"] == false).length}", Colors.orange[100], "checked"),
                  _infoContainer("Available", "${bl.books.where((e) => e["available"] == true).length}", Colors.greenAccent[100], "available"),
                ],

              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _infoContainer("Overdue", "${bl.books.where((e) => ((e["time_stamp"] * 1000) + 1629331200 < DateTime.now().millisecondsSinceEpoch.toInt()) && !e["available"]).length}", Colors.redAccent[100], "due"),
                  _infoContainer("Total", bl.books.length.toString(), Colors.lightBlueAccent[100], "all"),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoContainer(String title, body, Color? color, String use) {
    return Container(
      margin: const EdgeInsets.fromLTRB(2,30,2,2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          MaterialButton(
            height: 100,
            minWidth: 150,
            color: color,
            onPressed: () async => {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => ListPage(use: use,))),
              API(context).getAllBooks(),
            },
            child: Text(
              body,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0,20,0,60),
      child: MaterialButton(
        height: 100,
        minWidth: 220,
        elevation: 6,
        color: Colors.greenAccent[200],
        onPressed: () => {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const UpdatePage()))
        },
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        child: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.green[50],
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // row for top icons
            _topIcons(),
            //Title
            _title(),
            // Indicators
            _infoPanel(),
            // button for checking-out/returning books
            _actionButton(),
          ],
        ),
      )
    );
  }
}