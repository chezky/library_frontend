import 'package:flutter/material.dart';
import 'account.dart';
import 'dialogs/add_scan.dart';
import 'models/book_list.dart';
import 'package:library_frontend/models/books_scanned.dart';
import 'package:provider/provider.dart';

import 'api.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key ?key, this.use}) : super(key: key);

  final String? use;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    API(context).getAllBooks();
  }

  _checkedOutOwner(String customer, int id) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage(
          name: customer,
          tag: id,
        )));
      },
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Customer:",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            customer,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  _checkedOutDate(int date) {
    print(date.toString());
    return Column (
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Date:",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        Text(
          "${_formatDate(date)} day${_formatDate(date) != 1 ? '\'s' : ''} ago",
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _tile(int idx, bl) {
    return Dismissible(
      key: Key("${bl["id"]}_$idx}"),
      // Background: Container(color: Colors.red),
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm"),
              content: Text('Are you sure you wish to permanently delete ${bl["title"]} ?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction){
        context.read<BookList>().remove(bl);
        API(context).deleteBook(bl["id"]);
      },
      child: ExpansionTile(
        textColor: Colors.greenAccent[700],
        iconColor: Colors.greenAccent[700],
        title: Text(
          bl["title"],
        ),
        subtitle: Text(
          bl["author"],
        ),
        leading: Icon(
          Icons.circle,
          color: bl["available"] ? Colors.green[400] : Colors.red[400],
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!bl["available"]) _checkedOutOwner(bl["customer"], bl["customer_id"]),
              if(bl["time_stamp"] != 0) _checkedOutDate(bl["time_stamp"]),
              if (!bl["available"]) IconButton(
                onPressed: () {
                  API(context).returnBook(bl["id"]);
                  context.read<BookList>().remove(bl);

                },
                icon: const Icon(Icons.keyboard_return_outlined),
              ),
              if (bl["available"]) IconButton(
                onPressed: () => {
                  context.read<BooksScanned>().add(bl)
                },
                icon: const Icon(Icons.add_shopping_cart_rounded),
              ),
              IconButton(
                icon: const Icon(
                  Icons.scanner_outlined,
                ),
                onPressed: () {
                  showDialog(context: context, builder: (context) => AddScanDialog(title: bl["title"], id: bl["id"]));
                },
              ),
            ],
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);

    return GestureDetector(
      onTap: () {
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        // No appbar provided to the Scaffold, only a body with a
        // CustomScrollView.
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Add the app bar to the CustomScrollView.
              SliverAppBar(
                // Provide a standard title.
                // Allows the user to reveal the app bar if they begin scrolling
                // back up the list of items.
                floating: true,
                iconTheme: IconThemeData(
                  color: Colors.grey[600],
                ),
                // Display a placeholder widget to visualize the shrinking size.
                flexibleSpace: Padding(
                  padding: const EdgeInsets.fromLTRB(15,30,15,0),
                  child: Center(
                    child: TextField(
                      controller: searchController,
                      onChanged: (s) => API(context).getByTitle(s),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded,
                          color: Colors.greenAccent[700],
                        ),
                        suffixIcon: searchController.value.text.isNotEmpty ? IconButton(
                          icon: const Icon(Icons.cancel_outlined),
                          color: Colors.red[400],
                          onPressed: () => {
                            searchController.text = "",
                            API(context).getAllAccounts(),
                          },
                        ) : null,
                        hintText: "Search by title, author, or customer",
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                  ),
                ),
                // Make the initial height of the SliverAppBar larger than normal.
                expandedHeight: 150,
                backgroundColor: Colors.green[50],
              ),
              // Next, create a SliverList
              SliverList(
                // Use a delegate to build items as they're scrolled on screen.
                delegate: SliverChildBuilderDelegate(
                  // The builder function returns a ListTile with a title that
                  // displays the index of the current item.
                  (context, idx) => Consumer<BookList>(
                    builder: (context, bl, wdgt) {
                      switch (widget.use) {
                        case "all":
                          return context.watch<BookList>().books.isNotEmpty ? _tile(idx, bl.books[idx]) : Center(child: Text('No Results'));
                        case "available":
                          return context.watch<BookList>().books.isNotEmpty ? bl.books[idx]["available"] ? _tile(idx, bl.books[idx]) : Container() : Center(child: Text('No Results'));
                        case "checked":
                          return context.watch<BookList>().books.isNotEmpty ? !bl.books[idx]["available"] ? _tile(idx, bl.books[idx]) : Container() : Center(child: Text('No Results'));
                        case "due":
                          return context.watch<BookList>().books.isNotEmpty ? ((bl.books[idx]["time_stamp"] * 1000) + 1629331200 < DateTime.now().millisecondsSinceEpoch.toInt() && !bl.books[idx]["available"]) ? _tile(idx, bl.books[idx]) : Container() : Center(child: Text('No Results'));
                      }
                      return const Text('No Results');
                    },
                  ),
                  // Builds 1000 ListTiles
                  childCount: context.watch<BookList>().books.isNotEmpty ? context.read<BookList>().books.length : 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  int _formatDate(int date) {
    return DateTime.fromMillisecondsSinceEpoch(date * 1000).difference(DateTime.now()).inDays.toInt() * -1;
  }
}