import 'package:flutter/material.dart';

class DeleteDialog extends StatefulWidget {
  const DeleteDialog({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog>{
  @override

  Widget _centerWidget() {
    return Container(
      child: Text(
        'Are you sure you want to delete ${widget.title}?',
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Delete Book',
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
        TextButton(
          onPressed: () => Navigator.pop(context, 'delete'),
          child: const Text(
            'Delete',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
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
}