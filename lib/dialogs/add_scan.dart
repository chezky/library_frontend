import 'package:flutter/material.dart';

import 'package:nfc_manager/nfc_manager.dart';

class AddScanDialog extends StatefulWidget {
  const AddScanDialog({Key? key, this.title, this.id}) : super(key: key);
  final String? title;
  final int? id;

  @override
  State<AddScanDialog> createState() => _AddScanDialogState();
}

class _AddScanDialogState extends State<AddScanDialog> with TickerProviderStateMixin{
  late AnimationController controller;
  String bodyText = "Please wait to scan";
  bool scanned = false;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..addListener(() {
          setState(() {

          });
        });
    controller.repeat(reverse: true);

    _checkNFCAvailable();
    super.initState();
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    controller.dispose();
    super.dispose();
  }

  Widget _centerWidget() {
    return scanned ? const Icon(
     Icons.check,
      color: Colors.green,
    ) : CircularProgressIndicator(
      value: controller.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Scan a Book',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            bodyText,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
          ),
          _centerWidget(),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'skip'),
          child: const Text('Skip'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'cancel'),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Future<bool> _checkNFCAvailable() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (isAvailable) {
      setState(() {
        bodyText = 'Ready to scan ${widget.title}';
      });

      // if available, write to the tag
      _write();
    } else {
      setState(() {
        bodyText = 'No NFC on this device.';
      });
    }
    return isAvailable;
  }

  _write() async {
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);

        NdefMessage message = NdefMessage([
          //TODO: change this to be dynamic
          NdefRecord.createText(widget.id.toString()),
        ]);

        try {
          await ndef!.write(message);
          print('success');
          setState(() {
            scanned = true;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            NfcManager.instance.stopSession();
            Navigator.pop(context, 'success');
          });
        } catch (e) {
          NfcManager.instance.stopSession(errorMessage: e.toString());
          return;
        }
      }
    );
  }
}