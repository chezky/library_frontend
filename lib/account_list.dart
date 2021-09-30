import 'package:flutter/material.dart';
import 'package:library_frontend/account.dart';
import 'package:library_frontend/models/accounts_list.dart';
import 'package:provider/provider.dart';

import 'api.dart';
import 'models/account.dart';
import 'new_account.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({Key? key, required this.checkout}) : super(key: key);

  final bool checkout;

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  TextEditingController searchController = TextEditingController();

  Future _deleteDialog(int id) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text(
              'Are you sure you wish to permanently delete this account?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                API(context).deleteAccount(id);
                Navigator.of(context).pop(true);
              },
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onChanged: (s) => API(context).searchAccounts(s),
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
                      hintText: "Search by name or email",
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
                    (context, idx) => Consumer<AccountsList>(
                      builder: (context, bl, wdgt) {
                        return bl.accounts.isEmpty ? Center(
                          child: Column(
                            children: [
                              const Text(
                                'No Accounts Found',
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAccountPage())),
                                child: const Text("Tap to create one"),
                              ),
                            ],
                          ),
                        ) : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          child: SizedBox(
                              width: 100,
                              height: 170,
                              child: Hero(
                                tag: bl.accounts[idx]["id"],
                                child: Material(
                                  type: MaterialType.transparency, // likely needed
                                  child: MaterialButton(
                                    color: Colors.greenAccent[100],
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    onPressed: () {
                                      if (widget.checkout) {
                                        context.read<Account>().set({"id": bl.accounts[idx]["id"], "name": bl.accounts[idx]["name"], "book_count": bl.accounts[idx]["book_count"]});
                                        Navigator.pop(context);
                                      } else {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage(
                                          name: bl.accounts[idx]["name"],
                                          tag: bl.accounts[idx]["id"],
                                          email: bl.accounts[idx]["email"],
                                          bookCount:  bl.accounts[idx]["book_count"],
                                        )));
                                        API(context).getAccountByID(bl.accounts[idx]["id"]);
                                      }
                                    },
                                    onLongPress: () async {
                                      await _deleteDialog(bl.accounts[idx]["id"]);
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                bl.accounts[idx]["name"],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Text(bl.accounts[idx]["email"],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                       Padding(
                                         padding: const EdgeInsets.only(right: 30),
                                          child:  Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                               Container(
                                                 height: 40,
                                                 width: 40,
                                                 child: Center(
                                                   child: Text(bl.accounts[idx]["book_count"].toString()),
                                                 ),
                                                 decoration: BoxDecoration(
                                                   color: Colors.orange[200],
                                                   shape: BoxShape.circle,
                                                 ),
                                               ),
                                               Container(
                                                 height: 40,
                                                 width: 40,
                                                 decoration: const BoxDecoration(
                                                   shape: BoxShape.circle,
                                                 ),
                                               ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ),
                        );
                      },
                    ),
                // Builds 1000 ListTiles
                childCount: context.watch<AccountsList>().accounts.isNotEmpty ? context.read<AccountsList>().accounts.length : 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
