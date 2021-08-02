import 'package:flutter/material.dart';
import 'dialogs/add_scan.dart';
import 'package:library_frontend/api.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({Key? key}) : super(key: key);

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();

  bool switchValue = true;

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
    return Container(
      padding: const EdgeInsets.fromLTRB(0,40,0,0),
      child: Text(
        'Add a Book',
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w200,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _form() {
    return Container(
      padding: const EdgeInsets.only(top: 40),
      child: Column (
        children: [
          _textField("Title", 0, _titleController),
          _textField("Author", 1, _authorController),
        ],
      ),
    );
  }

  Widget _textField(String text, int id, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30,20,30,0),
      child: TextField(
        controller: controller,
        autofocus: id == 0,
        textInputAction: id == 0 ? TextInputAction.next : TextInputAction.done,
        decoration: InputDecoration(
          labelText: text,
        ),
      ),
    );
  }

  Widget _addMoreBool() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40,40,20,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Text(
            'Add another book',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Switch(
            value: switchValue,
            onChanged: (value) {
              setState(() {
                switchValue = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _submit() {
    return Container(
      padding: EdgeInsets.fromLTRB(0,MediaQuery.of(context).size.height*0.1,0,60),
      child: MaterialButton(
        height: 70,
        minWidth: 150,
        elevation: 6,
        color: Colors.greenAccent[200],
        onPressed: _titleController.value.text.isNotEmpty ?  () => {
          _addBook(),
        } : null,
        disabledColor: Colors.grey[300],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        child: const Text(
          'Submit',
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
    FocusScopeNode currentFocus = FocusScope.of(context);

    return GestureDetector(
      onTap: () {
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Material(
        color: Colors.green[50],
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _topIcon(),
                _title(),
                _form(),
                _addMoreBool(),
                _submit(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _handleDialog(value) {
    if(value == "skip" || value == "success") {
      switchValue ? _reset() : Navigator.pop(context);
    }
  }

  _reset() {
    _titleController.clear();
    _authorController.clear();
  }
  
  _addBook() async {
    if (_titleController.value.text != "") {
      int result = await API(context).addBook(_titleController.value.text, _authorController.value.text);
      print("result of adding a new book: ${result.toString()}");
      showDialog(context: context, builder: (context) => AddScanDialog(title: _titleController.value.text, id: result)).then((value) => _handleDialog(value));
    }
  }
}