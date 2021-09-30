import 'package:flutter/material.dart';
import 'package:library_frontend/api.dart';
import 'package:library_frontend/models/account.dart';
import 'package:provider/src/provider.dart';

import 'edit_account.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key, required this.name, required this.tag, this.email, this.bookCount}) : super(key: key);

  final String name;
  final int tag;
  final String? email;
  final int? bookCount;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _name = "";
  String _email ="";
  int _bookCount = 0;
  bool _emailList = true;
  var _books = [];

  @override
  void initState() {
    _name = widget.name;
    _email = widget.email ?? "";
    _bookCount = widget.bookCount ?? 0;
    _getAccount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Material(
          child: CustomScrollView(
            slivers: [
              // Add the app bar to the CustomScrollView.
              SliverAppBar(
                // Provide a standard title.
                // Allows the user to reveal the app bar if they begin scrolling
                // back up the list of items.
                floating: true,
                automaticallyImplyLeading: false,
                iconTheme: IconThemeData(
                  color: Colors.grey[600],
                ),
                // leading: Text(""),
                flexibleSpace: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_outlined),
                            ),
                            IconButton(
                              onPressed: (){
                                context.read<Account>().set({"id": widget.tag, "name": _name, "book_count": _bookCount});
                              },
                              icon: const Icon(Icons.shopping_cart_outlined),
                            ),
                          ],
                        ),
                      ),
                      Hero(
                        tag: widget.tag,
                        child: Material(
                          type: MaterialType.transparency, // likely needed
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(30),),
                              color: Colors.greenAccent[100],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 50, top: 70),
                                      child: Column(
                                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _name,
                                            style: const TextStyle(
                                              fontSize: 24,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 50, bottom: 65),
                                            child: Text(
                                              _email,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 50, top: 70),
                                      child:  Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            height: 40,
                                            width: 40,
                                            child: Center(
                                              child: Text(_bookCount.toString()),
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[200],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 30),
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              child: IconButton(
                                                icon: Icon(Icons.edit),
                                                onPressed: (){
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditAccountPage(name: _name, email: _email,)))
                                                      .then((v) {
                                                        if (v != null) {
                                                          setState(() {
                                                            _name = v["name"];
                                                            _email = v["email"];
                                                          });
                                                          API(context).updateAccount(widget.tag, _name, _email, _emailList);
                                                        }
                                                  });
                                                },
                                                color: Colors.grey[600],
                                              ),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(50, 10, 50, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Email List"),
                              Switch(
                                value: _emailList,
                                onChanged: (v) async {
                                   String res = await API(context).updateAccount(widget.tag, _name, _email, v);
                                   if (res == "success") {
                                     setState(() {
                                       _emailList = !_emailList;
                                     });
                                   }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                // Make the initial height of the SliverAppBar larger than normal.
                // expandedHeight: 300,
                toolbarHeight: 375,
                backgroundColor: Colors.green[50],
              ),
              // Next, create a SliverList
              SliverList(
                // Use a delegate to build items as they're scrolled on screen.
                delegate: SliverChildBuilderDelegate(
                  // The builder function returns a ListTile with a title that
                  // displays the index of the current item.
                      (context, idx) =>  _books.isEmpty ? Center(child:Text("No Books"),) : ExpansionTile(
                        textColor: Colors.greenAccent[700],
                        iconColor: Colors.greenAccent[700],
                        title: Text(
                          _books[idx]["title"],
                        ),
                        subtitle: Text(
                          _books[idx]["author"],
                        ),
                        leading: Icon(
                          Icons.circle,
                          color: Colors.red[400],
                        ),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column (
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Date:",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "${_formatDate(_books[idx]["time_stamp"])} day${_formatDate(_books[idx]["time_stamp"]) != 1 ? '\'s' : ''} ago",
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.keyboard_return_outlined,
                                ),
                                onPressed: () => returnBook(_books[idx]["id"]),
                              ),
                              IconButton(
                                onPressed: () => {
                                  // context.read<BooksScanned>().add(_books["books"][idx])
                                },
                                icon: const Icon(Icons.add_shopping_cart_rounded),
                              ),
                            ],
                          )
                        ],
                      ),
                  // Builds 1000 ListTiles
                  childCount: _books.isEmpty ? 1 : _books.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getAccount() async {
    var account = await API(context).getAccountByID(widget.tag);
    if (account != "error") {
      setState(() {
        _name = account["name"];
        _email = account["email"];
        _bookCount = account["book_count"];
        _emailList = account["email_list"];
        if (account["books"] != null) {
          _books = account["books"];
        }
      });
    }
  }

  void returnBook(int bookID) async {
    String res = await API(context).returnBook(bookID);
    if (res == "success") {
      setState(() {
        _bookCount -= 1;
        _books.removeWhere((e) => e["id"] == bookID);
      });
    }
  }

  int _formatDate(int date) {
    return DateTime.fromMillisecondsSinceEpoch(date * 1000).difference(DateTime.now()).inDays.toInt() * -1;
  }
}