import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:library_frontend/api.dart';
import 'dialogs/customer.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

import 'models/books_scanned.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({Key? key}) : super(key: key);

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  String actionText = "Scan a Book";

  @override
  void initState() {
    _checkNFCAvailable();
    _read();
    super.initState();
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  Widget _title() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0,50,0,0),
      child: const Text(
        'Checkout',
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w200,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _bookList() {
    return Consumer<BooksScanned>(
      builder: (context, bl, wdgt) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
          child: ListView.builder(
            itemCount: bl.books.length,
            itemBuilder: (BuildContext ctxt, int idx) {
              return ListTile(
                leading: Icon(Icons.book_outlined, color: Colors.green[200],),
                title: Text(
                  bl.books[idx]["title"],
                ),
                subtitle: Text(
                  bl.books[idx]["author"],
                ),
                trailing: IconButton(
                  onPressed: () {
                    context.read<BooksScanned>().remove(idx);
                  },
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: Colors.red[200],
                  ),
                ),
              );
            }
          ),
        );
      }
    );
  }

  // Widget _actionButton() {
  //   return Container(
  //     padding: EdgeInsets.fromLTRB(0,40,0,0),
  //     child: MaterialButton(
  //       onPressed: () {
  //         showDialog(context: context, builder: (context) => ReadScanDialog()).then((value) => _handleDialog(value));
  //       },
  //       height: 80,
  //       minWidth: 185,
  //       child: Text(
  //         actionText,
  //         style: const TextStyle(
  //           fontSize: 18,
  //         ),
  //       ),
  //       color: Colors.greenAccent[400],
  //       shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.all(Radius.circular(50)),
  //       ),
  //     ),
  //   );
  // }

  Widget _submitButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(0,40,0,0),
      child: MaterialButton(
        onPressed: () {
          _checkout();
        },
        height: 80,
        minWidth: 185,
        child: const Text(
          "Checkout",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        color: Colors.greenAccent[400],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
      ),
    );
  }

  SnackBar _snack(String text) {
    return SnackBar(
      padding: const EdgeInsets.fromLTRB(20,20,20,20),
      margin: const EdgeInsets.fromLTRB(20,10,20,10),
      behavior: SnackBarBehavior.floating,
      content: Text(text),
      duration: const Duration(milliseconds: 1500),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _title(),
            _bookList(),
            // _actionButton(),
            _submitButton(),
          ],
        ),
      ),
    );
  }

  _handleScan(val) async {
      Map book = await API(context).getBookByID(val) ?? {};
      if (book.isNotEmpty && !book["available"]) {
        API(context).returnBook(book["id"]);
        ScaffoldMessenger.of(context).showSnackBar(_snack("${book["title"]} returned."));
      }
  }

  _read() async {
    NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          String data = utf8.decode(tag.data["ndef"]["cachedMessage"]["records"][0]["payload"]).substring(3);
          print('data is $data');
          _handleScan(data);
          // NfcManager.instance.stopSession();
        }
    );
  }
  
  _checkout() async {
    if (context.read<BooksScanned>().books.isNotEmpty) {
      showDialog(context: context, builder: (context) => const CustomerDialog()).then((value) => _handleDialog(value));
    }
  }

  _handleDialog(String value) {
    print(value);
  }

  Future<bool> _checkNFCAvailable() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(_snack("No NFC."));
      });
    }
    return isAvailable;
  }
}