import 'dart:async';

import 'package:ep_cf_catch/model/table/branch.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/catching/catching_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationSelection extends StatefulWidget {
  @override
  _LocationSelectionState createState() => _LocationSelectionState();
}

class _LocationSelectionState extends State<LocationSelection> {

  var searchTec = TextEditingController();
  Timer _debounce;

  @override
  void dispose() {
    searchTec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CatchingBloc>(context);

    searchTec.addListener(() {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        String filter = searchTec.text;
        bloc.searchLocation(filter);
      });
    });

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<bool>(
            stream: bloc.isScanStream,
            initialData: false,
            builder: (context, snapshot) {
              return TextField(
                enabled: !snapshot.data,
                controller: searchTec,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: Strings.search,
                  contentPadding: const EdgeInsets.all(8.0),
                ),
              );
            }
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Branch>>(
            stream: bloc.locListStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              var list = snapshot.data;
              return ListView.separated(
                separatorBuilder: (ctx, index) => Divider(height: 0),
                itemCount: list.length,
                itemBuilder: (ctx, position) {
                  var location = list[position];

                  return StreamBuilder<int>(
                      stream: bloc.selectedLocationIdStream,
                      builder: (context, snapshot) {
                        var bgColor = Theme.of(ctx).scaffoldBackgroundColor;
                        var isSelected = false;

                        if (snapshot.data == location.id) {
                          bgColor = Theme.of(ctx).primaryColorLight;
                          isSelected = true;
                        }
                        return Container(
                          color: bgColor,
                          child: ListTile(
                            leading: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.location_on),
                            ),
                            title: Text(location.branchName),
                            subtitle: Text(location.branchCode),
                            onTap: () {
                              bloc.setLocationId(location.id);
                            },
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (b) {
                                bloc.setLocationId(location.id);
                              },
                            ),
                          ),
                        );
                      });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
