import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/catching_detail/catching_detail_bloc.dart';
import 'package:ep_cf_catch/screen/catching_detail/widget/bluetooth_panel.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class DetailEntry extends StatefulWidget {
  @override
  _DetailEntryState createState() => _DetailEntryState();
}

class _DetailEntryState extends State<DetailEntry> with AutomaticKeepAliveClientMixin{
  var houseNoTec = TextEditingController();
  var ageTec = TextEditingController();
  var weightTec = TextEditingController();
  var qtyTec = TextEditingController();
  var weightFn = FocusNode();


  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  void initState() {
    super.initState();
    houseNoTec.text = "1";
  }


  @override
  void dispose() {
    houseNoTec.dispose();
    ageTec.dispose();
    weightTec.dispose();
    qtyTec.dispose();
    weightFn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CatchingDetailBloc>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: houseNoTec,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: Strings.houseCode,
                    contentPadding: const EdgeInsets.all(8),
                    prefixIcon: Icon(Icons.home)),
              ),
            ),
            Container(width: 8),
            Expanded(
              child: TextField(
                controller: ageTec,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: Strings.age,
                    contentPadding: const EdgeInsets.all(8),
                    prefixIcon: Icon(FontAwesomeIcons.hashtag)),
              ),
            ),
            Container(width: 8),
            Expanded(
              child: TextField(
                controller: qtyTec,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: Strings.quantity,
                  contentPadding: const EdgeInsets.all(8),
                  prefixIcon: Icon(FontAwesomeIcons.dove),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            Strings.cageQuantity,
            style: TextStyle(fontSize: 12),
          ),
        ),
        StreamBuilder<int>(
            stream: bloc.cageQtyStream,
            builder: (context, snapshot) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var i = 1; i <= 4; i++)
                    Row(
                      children: [
                        Radio(
                          value: i,
                          groupValue: snapshot.data,
                          onChanged: (value) {
                            bloc.setCateQty(value);
                          },
                        ),
                        Text(i.toString()),
                      ],
                    )
                ],
              );
            }),
        Text(
          Strings.coverQuantity,
          style: TextStyle(fontSize: 12),
        ),
        StreamBuilder<int>(
          stream: bloc.cageQtyStream,
          builder: (context, snapshot) {
            var cage = 0;
            if (snapshot.data != null) {
              cage = snapshot.data;
            }
            return StreamBuilder<int>(
                stream: bloc.coverQtyStream,
                builder: (context, snapshot) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var i = 0; i <= cage; i++)
                        Row(
                          children: [
                            Radio(
                              value: i,
                              groupValue: snapshot.data,
                              onChanged: (value) {
                                bloc.setCoverQty(value);
                              },
                            ),
                            Text(i.toString()),
                          ],
                        )
                    ],
                  );
                });
          },
        ),
        BluetoothPanel(),
        SizedBox(
          width: double.infinity,
          child: StreamBuilder<double>(
              stream: bloc.weightStream,
              builder: (context, snapshot) {
                var weight = 0.00;
                if (snapshot.hasData) {
                  weight = snapshot.data;
                }
                return RaisedButton.icon(
                  icon: Icon(Icons.arrow_downward),
                  color: Colors.black,
                  label: Text(
                    "${weight.toStringAsFixed(2)} Kg",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    if (bloc.getWeight() != null && bloc.getWeight() > 0) {
                      weightTec.text = bloc.getWeight()?.toStringAsFixed(2);
                      bloc.setIsWeighingByBt(true);
                    }
                  },
                );
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: StreamBuilder<bool>(
                    stream: bloc.isWeighingByBtStream,
                    initialData: false,
                    builder: (context, snapshot) {
                      return TextField(
                        enabled: !snapshot.data,
                        controller: weightTec,
                        focusNode: weightFn,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        autofocus: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: Strings.weightKg,
                            contentPadding: const EdgeInsets.all(8),
                            prefixIcon: Icon(FontAwesomeIcons.weight)),
                      );
                    }),
              ),
              IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  resetWeightField(bloc);
                },
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: RaisedButton.icon(
              icon: Icon(Icons.arrow_back),
              label: Text(Strings.save.toUpperCase()),
              onPressed: () async {
                final house = int.tryParse(houseNoTec.text);
                final age = int.tryParse(ageTec.text);
                final weight = double.tryParse(weightTec.text);
                final qty = int.tryParse(qtyTec.text);

                var res = await bloc.insertDetail(house, age, weight, qty);
                if (res) {
                  resetWeightField(bloc);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  void resetWeightField(CatchingDetailBloc bloc) {
    weightTec.text = "";
    bloc.setIsWeighingByBt(false);
    FocusScope.of(context).requestFocus(weightFn);
  }
}
