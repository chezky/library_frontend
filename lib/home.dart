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

  @override
  void initState() {
    API(context).getAllBooks();
    super.initState();
  }

  Widget _topIcons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10,20,10,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // IconButton(
          //   color: Colors.grey,
          //   onPressed: () => {
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => const AddBookPage()))
          //   },
          //   icon: const Icon(Icons.settings_rounded),
          // ),
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
          'FelsenBrary',
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
                  _infoContainer("Checked Out", "${bl.books.where((e) => e["available"] == false).length}", Colors.orange[400], "checked"),
                  _infoContainer("Available", "${bl.books.where((e) => e["available"] == true).length}", Colors.green[400], "available"),
                ],

              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _infoContainer("Overdue", "${bl.books.where((e) => ((e["time_stamp"] * 1000) + 1629331200 < DateTime.now().millisecondsSinceEpoch.toInt()) && !e["available"]).length}", Colors.red[400], "due"),
                  _infoContainer("Total", bl.books.length.toString(), Colors.purple[300], "all"),
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
            onPressed: () => {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ListPage(use: use,)))
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
        color: Colors.greenAccent[400],
        onPressed: () => {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const UpdatePage()))
        },
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        child: const Text(
          'Scan Books',
          style: TextStyle(
            fontSize: 25,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
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