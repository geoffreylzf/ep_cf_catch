import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/catching/catching_bloc.dart';
import 'package:ep_cf_catch/screen/catching_detail/catching_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HeadEntry extends StatefulWidget {
  @override
  _HeadEntryState createState() => _HeadEntryState();
}

class _HeadEntryState extends State<HeadEntry> {
  var recordDate = DateTime.now();
  var dateFormat = DateFormat('yyyy-MM-dd');
  var dateTec = TextEditingController();
  var docNoTec = TextEditingController();
  var truckNoTec = TextEditingController();
  var refNoTec = TextEditingController();

  @override
  void initState() {
    super.initState();
    dateTec.text = dateFormat.format(recordDate);
  }


  @override
  void dispose() {
    dateTec.dispose();
    docNoTec.dispose();
    truckNoTec.dispose();
    refNoTec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CatchingBloc>(context);
    return Column(
      children: [
        TextField(
          controller: dateTec,
          enableInteractiveSelection: false,
          focusNode: AlwaysDisabledFocusNode(),
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: recordDate,
              firstDate: DateTime(2010),
              lastDate: DateTime(2050),
            );

            if (selectedDate != null) {
              recordDate = selectedDate;
              dateTec.text = dateFormat.format(selectedDate);
            }
          },
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.date_range),
            labelText: Strings.recordDate,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: TextField(
            controller: docNoTec,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: Strings.documentNumber,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: TextField(
            controller: truckNoTec,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: Strings.truckCode,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: TextField(
            controller: refNoTec,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: Strings.referenceNumber,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: SizedBox(
            width: double.infinity,
            child: RaisedButton(
              child: Text(Strings.start.toUpperCase()),
              onPressed: () {
                final recordDate = dateTec.text;
                final docNo = docNoTec.text;
                final truckNo = truckNoTec.text;
                final refNo = refNoTec.text;
                final cfCatch =
                    bloc.validateEntry(recordDate, docNo, truckNo, refNo);
                if (cfCatch != null) {
                  Navigator.pushNamed(
                    context,
                    CatchingDetailScreen.route,
                    arguments: cfCatch,
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
