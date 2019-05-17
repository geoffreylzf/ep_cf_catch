import 'package:ep_cf_catch/bloc/bloc.dart';
import 'package:ep_cf_catch/db/dao/branch_dao.dart';
import 'package:ep_cf_catch/db/dao/cf_catch_dao.dart';
import 'package:ep_cf_catch/model/table/branch.dart';
import 'package:ep_cf_catch/model/table/cf_catch.dart';
import 'package:rxdart/rxdart.dart';

class CatchHistoryBloc extends BlocBase {
  final _cfCatchListSubject = BehaviorSubject<List<CfCatch>>();

  Stream<List<CfCatch>> get cfCatchListStream => _cfCatchListSubject.stream;

  @override
  void dispose() {
    _cfCatchListSubject.close();
  }

  CatchHistoryBloc() {
    loadCfCatchList();
  }

  loadCfCatchList() async {
    _cfCatchListSubject.add(await CfCatchDao().getList());
  }

  Future<Branch> getLocation(int locationId) async{
    return BranchDao().getLocationById(locationId);
  }
}
