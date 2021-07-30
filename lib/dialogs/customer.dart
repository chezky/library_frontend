import 'package:flutter/material.dart';

import '../api.dart';

class CustomerDialog extends StatefulWidget {
  const CustomerDialog({Key? key}) : super(key: key);

  @override
  State<CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<CustomerDialog> with SingleTickerProviderStateMixin{
  TextEditingController textController = TextEditingController();
  late AnimationController controller;

  bool loading = false;

  @override
  void initState() {
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
    controller.dispose();
    super.dispose();
  }

  Widget _centerWidget() {
   return Container(
     child: TextField(
       controller: textController,
       autofocus: true,
       textInputAction: TextInputAction.done,
       onSubmitted: (s) => {
         _checkout()
       },
       onEditingComplete: () {
         _checkout();
       },
       decoration: const InputDecoration(
         labelText: "Name",
         border: OutlineInputBorder(
           borderRadius: BorderRadius.all(Radius.circular(5)),
         ),
       ),
     ),
   );
  }

  Widget _submitButton() {
    return loading ? CircularProgressIndicator(
      value: controller.value,
    ) : TextButton(
      onPressed: () => {
        _checkout()
      },
      child: const Text('Submit'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Type Your Name',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 20),
          ),
          _centerWidget(),
        ],
      ),
      actions: <Widget>[
        _submitButton(),
        TextButton(
          onPressed: () => Navigator.pop(context, 'cancel'),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  _checkout() async {
    if (textController.value.text.isNotEmpty) {
      setState(() {
        loading = true;
      });
      await API(context).updateBooks(textController.value.text);
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context, 'success');
      });
    }
  }
}