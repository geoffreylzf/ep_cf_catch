import 'package:ep_cf_catch/bloc/bloc.dart';
import 'package:ep_cf_catch/db/dao/branch_dao.dart';
import 'package:ep_cf_catch/model/table/branch.dart';
import 'package:ep_cf_catch/module/shared_preferences_module.dart';
import 'package:rxdart/rxdart.dart';

class CompanyBloc extends BlocBase{
  final _coyListSubject = BehaviorSubject<List<Branch>>();

  Stream<List<Branch>> get coyListStream => _coyListSubject.stream;

  @override
  void dispose() {
    _coyListSubject.close();
  }

  CompanyBloc() {
    _loadCoyList();
  }

  _loadCoyList() async {
    _coyListSubject.add(await BranchDao().getCompanyList());
  }

  setCompanyId(int companyId) async {
    await SharedPreferencesModule().saveCompanyId(companyId);
  }
}
