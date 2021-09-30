import 'package:flutter/material.dart';
import 'dialogs/add_scan.dart';
import 'package:library_frontend/api.dart';

class EditAccountPage extends StatefulWidget {
  EditAccountPage({Key? key, required this.name, required this.email}) : super(key: key);

  String name = "";
  String email = "";

  @override
  State<EditAccountPage> createState() => _EditAccountPage();
}

class _EditAccountPage extends State<EditAccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    _nameController.text = widget.name;
    _emailController.text = widget.email;
    super.initState();
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
    return Container(
      padding: const EdgeInsets.fromLTRB(0,40,0,0),
      child: Text(
        'Edit an Account',
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
          _textField("Name", 0, _nameController),
          _textField("Email", 1, _emailController),
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

  Widget _submit() {
    return Container(
      padding: EdgeInsets.fromLTRB(0,MediaQuery.of(context).size.height*0.1,0,60),
      child: MaterialButton(
        height: 70,
        minWidth: 150,
        elevation: 6,
        color: Colors.greenAccent[200],
        onPressed: _nameController.value.text.isNotEmpty && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.value.text) ?  () => {
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
                _submit(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _addBook() async {
    Map val = {"name": API(context).parseWord(_nameController.value.text), "email": _emailController.value.text};
    Navigator.pop(context, val);
  }
}