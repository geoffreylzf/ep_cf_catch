import 'package:ep_cf_catch/bloc/bloc.dart';
import 'package:ep_cf_catch/module/shared_preferences_module.dart';
import 'package:rxdart/rxdart.dart';

class LocalBloc extends BlocBase {
  final _localCheckedSubject = BehaviorSubject<bool>();

  Stream<bool> get localCheckedStream => _localCheckedSubject.stream;

  @override
  void dispose() {
    _localCheckedSubject.close();
  }

  LocalBloc() {
    loadLocalChecked();
  }

  loadLocalChecked() async {
    _localCheckedSubject.add(await SharedPreferencesModule().getLocalCheck() ?? false);
  }

  setLocalChecked(bool b) async {
    await SharedPreferencesModule().saveLocalCheck(b);
    _localCheckedSubject.add(b);
  }
}
