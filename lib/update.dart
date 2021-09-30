import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:library_frontend/api.dart';
import 'account_list.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

import 'models/account.dart';
import 'models/books_scanned.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({Key? key}) : super(key: key);

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> with TickerProviderStateMixin {
  late AnimationController controller;

  String actionText = "Scan a Book";
  bool scannedEmpty = true;
  bool _loading = false;

  @override
  void initState() {
    _checkNFCAvailable();
    _read();

    controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(() {
        setState(() {

        });
      });
    controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    controller.dispose();
    super.dispose();
  }

  Widget _topIcon() {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.grey,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0,10,0,20),
      child: Column(
        children: [
          Text(
            'Checkout for',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w200,
              color: Colors.grey[600],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountListPage(checkout: true)));
            },
            child: Text(
              context.watch<Account>().account.isNotEmpty ? context.watch<Account>().account["name"] : "Tap to search",
              style: TextStyle(
                fontSize: 27,
                color: Colors.greenAccent[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookList() {
    return Consumer<BooksScanned>(
      builder: (context, bl, wdgt) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
          child: bl.books.isEmpty ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            child: const Center(
              child: Text(
                'Please scan a book to return or checkout.',
              ),
            ),
          ) : ListView.builder(
            itemCount: bl.books.length,
            itemBuilder: (BuildContext ctxt, int idx) {
              return ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 5),
                  child: Icon(
                    Icons.book_outlined,
                    color: Colors.green[400],
                  ),
                ),
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
                    color: Colors.red[400],
                  ),
                ),
              );
            }
          ),
        );
      }
    );
  }

  Widget _submitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0,40,0,0),
      child: _loading ? CircularProgressIndicator(
        value: controller.value,
      ) :
      MaterialButton(
        onPressed: context.watch<BooksScanned>().books.isNotEmpty && context.watch<Account>().account.isNotEmpty ? () {
          _checkout();
        } : null,
        disabledColor: Colors.grey[300],
        height: 80,
        minWidth: 185,
        child: const Text(
          "Checkout",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        color: Colors.greenAccent[200],
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _topIcon(),
              _title(),
              _bookList(),
              _submitButton(),
            ],
          ),
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
          if (int.tryParse(data) != null) {
            _handleScan(data);
          }
        }
    );
  }
  
  _checkout() async {
    setState(() {
      _loading = !_loading;
    });
    String res = await API(context).updateBooks();
    if (res == "success") {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _loading = !_loading;
        });
        context.read<Account>().account.clear();
      });
    } else {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(_snack("Error Occurred"));
      });
    }
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