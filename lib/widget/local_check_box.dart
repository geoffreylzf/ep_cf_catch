import 'package:ep_cf_catch/bloc/local_bloc.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:flutter/material.dart';

class LocalCheckBox extends StatefulWidget {
  final LocalBloc localBloc;

  LocalCheckBox({@required this.localBloc});

  @override
  _LocalCheckBoxState createState() => _LocalCheckBoxState();
}

class _LocalCheckBoxState extends State<LocalCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        StreamBuilder<bool>(
            stream: widget.localBloc.localCheckedStream,
            initialData: false,
            builder: (context, snapshot) {
              return Checkbox(
                value: snapshot.data,
                onChanged: (bool b) {
                  widget.localBloc.setLocalChecked(b);
                },
              );
            }),
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            Strings.localConnectOfficeWifi,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }
}
