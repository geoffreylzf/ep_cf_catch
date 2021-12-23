import 'package:ep_cf_catch/bloc/bloc.dart';
import 'package:ep_cf_catch/db/dao/cf_catch_dao.dart';
import 'package:ep_cf_catch/db/dao/log_dao.dart';
import 'package:ep_cf_catch/db/dao/util_dao.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/model/table/cf_catch.dart';
import 'package:ep_cf_catch/model/table/log.dart';
import 'package:ep_cf_catch/model/upload_body.dart';
import 'package:ep_cf_catch/module/api_module.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class UploadBloc extends BlocBase {
  final _uploadLogListSubject = BehaviorSubject<List<Log>>();
  final _noUploadCountSubject = BehaviorSubject<int>();
  final _isLoadingSubject = BehaviorSubject<bool>.seeded(false);

  Stream<List<Log>> get uploadLogListStream => _uploadLogListSubject.stream;

  Stream<int> get noUploadCountStream => _noUploadCountSubject.stream;

  Stream<bool> get isLoadingStream => _isLoadingSubject.stream;

  @override
  void dispose() {
    _uploadLogListSubject.close();
    _noUploadCountSubject.close();
    _isLoadingSubject.close();
  }

  SimpleAlertDialogMixin _simpleAlertDialogMixin;

  UploadBloc({@required SimpleAlertDialogMixin mixin}) {
    _simpleAlertDialogMixin = mixin;
    _init();
  }

  _init() async {
    await loadLog();
    await loadNoUploadCount();
  }

  loadLog() async {
    _uploadLogListSubject.add(await LogDao().getAllByTask(Log.logTaskUpload));
  }

  loadNoUploadCount() async {
    _noUploadCountSubject.add(await UtilDao().getNoUploadCount());
  }

  upload() async {
    if (_noUploadCountSubject.value != 0) {
      try {
        _isLoadingSubject.add(true);
        final cfCatchList = await _getPreparedUploadData();
        final uploadBody = UploadBody(cfCatchList: cfCatchList);

        final idList = (await ApiModule().upload(uploadBody)).result.cfCatchIdList;

        await _updateUploadStatus(ids: idList);

        await _insertLog(Log.logTaskUpload, "${idList.length.toString()} record(s) uploaded");

        await loadLog();
        await loadNoUploadCount();

        _simpleAlertDialogMixin.onDialogMessage(Strings.success, "Upload complete.");
      } catch (e) {
        _simpleAlertDialogMixin.onDialogMessage(Strings.error, e.toString());
      } finally {
        _isLoadingSubject.add(false);
      }
    } else {
      _simpleAlertDialogMixin.onDialogMessage(Strings.error, "No data to upload.");
    }
  }

  Future<List<CfCatch>> _getPreparedUploadData() async {
    final cfCatchList = await CfCatchDao().getByUpload(isUpload: 0);
    await Future.forEach(cfCatchList, (cfCatch) async {
      await (cfCatch as CfCatch).loadDetailList();
      await (cfCatch as CfCatch).loadWorkerList();
    });

    return cfCatchList;
  }

  _updateUploadStatus({
    @required List<int> ids,
    int uploadStatus = 1,
  }) async {
    await Future.forEach(ids, (id) async {
      final premix = await CfCatchDao().getById(id);
      premix.isUpload = 1;
      await CfCatchDao().update(premix);
    });
  }

  _insertLog(String task, remark) async {
    final log = Log.dbInsert(
      task: task,
      remark: remark,
    );
    log.setCurrentTimestamp();
    await LogDao().insert(log);
  }
}
