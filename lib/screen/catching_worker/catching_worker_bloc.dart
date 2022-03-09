import 'package:ep_cf_catch/bloc/bloc.dart';
import 'package:ep_cf_catch/db/dao/person_staff.dart';
import 'package:ep_cf_catch/db/dao/temp_cf_catch_worker_dao.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/model/table/person_staff.dart';
import 'package:ep_cf_catch/model/table/temp_cf_catch_worker.dart';
import 'package:ep_cf_catch/module/api_module.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CatchingWorkerBloc extends BlocBase {
  final _isFetchingSubject = BehaviorSubject<bool>();
  final _personStaffListSubject = BehaviorSubject<List<PersonStaff>>();
  final _tempListSubject = BehaviorSubject<List<TempCfCatchWorker>>();
  final _isFarmWorkerSubject = BehaviorSubject<bool>.seeded(false);

  Stream<List<PersonStaff>> get personStaffListStream => _personStaffListSubject.stream;

  Stream<bool> get isFetchingStream => _isFetchingSubject.stream;

  Stream<List<TempCfCatchWorker>> get tempListStream => _tempListSubject.stream;

  Stream<bool> get isFarmWorkerStream => _isFarmWorkerSubject.stream;

  @override
  void dispose() {
    _isFetchingSubject.close();
    _personStaffListSubject.close();
    _tempListSubject.close();
    _isFarmWorkerSubject.close();
  }

  SimpleAlertDialogMixin _simpleAlertDialogMixin;

  CatchingWorkerBloc({@required SimpleAlertDialogMixin mixin}) {
    _simpleAlertDialogMixin = mixin;
    _loadTempList();
    _loadPersonStaffList("");
  }

  _loadTempList() async {
    _tempListSubject.add(await TempCfCatchWorkerDao().getList());
  }

  _loadPersonStaffList(String filter) async {
    _personStaffListSubject.add(await PersonStaffDao().getPersonStaffListByFilter(filter));
  }

  searchPersonStaff(String filter) async {
    await _loadPersonStaffList(filter);
  }

  fetchPersonStaff() async {
    try {
      _isFetchingSubject.add(true);
      final personStaffResponse = await ApiModule().getPersonStaff();
      await PersonStaffDao().deleteAll();
      await Future.forEach(personStaffResponse.result, (ps) async {
        await PersonStaffDao().insert(ps);
      });

      await _loadPersonStaffList("");
      await TempCfCatchWorkerDao().deleteAll();
      await _loadTempList();

      _simpleAlertDialogMixin.onDialogMessage(
          Strings.success, "Latest worker successfully retrieve.");
    } catch (e) {
      _simpleAlertDialogMixin.onDialogMessage(Strings.error, e.toString());
    } finally {
      _isFetchingSubject.add(false);
    }
  }

  toggleIsFarmWorker() {
    _isFarmWorkerSubject.add(!_isFarmWorkerSubject.value);
  }

  Future<bool> insertWorker({int personStaffId, String workerName}) async {
    if (personStaffId == null && (workerName == null || workerName.trim() == '')) {
      _simpleAlertDialogMixin.onDialogMessage(Strings.error, "Please enter worker name");
      return false;
    }

    int isFarmWorker = 0;

    if (personStaffId != null) {
      final ps = _personStaffListSubject.value.firstWhere(
        (x) => x.id == personStaffId,
        orElse: () => null,
      );
      if (ps == null) {
        _simpleAlertDialogMixin.onDialogMessage(
          Strings.error,
          "Worker selection error, please try again",
        );
        return false;
      }

      workerName = ps.personName;
    } else {
      isFarmWorker = _isFarmWorkerSubject.value ? 1 : 0;
    }

    final temp = TempCfCatchWorker(
      personStaffId: personStaffId,
      workerName: workerName,
      isFarmWorker: isFarmWorker,
    );

    await TempCfCatchWorkerDao().insert(temp);
    await _loadTempList();

    if (_isFarmWorkerSubject.value) {
      _isFarmWorkerSubject.value = false;
    }

    return true;
  }

  deleteWorker(int id) async {
    await TempCfCatchWorkerDao().deleteById(id);
    await _loadTempList();
  }

  bool isWorkerInStaffList(personStaffId) {
    final isContain = _personStaffListSubject.value.map((x) => x.id).contains(personStaffId);
    if (isContain) {
      return true;
    }
    return false;
  }
}
