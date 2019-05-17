import 'package:flutter/material.dart';

class SimpleLoadingDialog extends StatefulWidget {
  final Stream<bool> stream;

  SimpleLoadingDialog(this.stream);

  @override
  _SimpleLoadingDialogState createState() => _SimpleLoadingDialogState();
}

class _SimpleLoadingDialogState extends State<SimpleLoadingDialog> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        initialData: false,
        stream: widget.stream,
        builder: (context, snapshot) {
          if (snapshot.data) {
            return Positioned.fill(
              child: Container(
                color: Colors.grey.withOpacity(0.5),
                child: Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 10,
                    ),
                  ),
                ),
              ),
            );
          }
          return Container();
        });
  }
}
