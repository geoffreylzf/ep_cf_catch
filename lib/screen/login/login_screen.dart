import 'package:ep_cf_catch/bloc/local_bloc.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/home/home_screen.dart';
import 'package:ep_cf_catch/screen/login/logic_bloc.dart';
import 'package:ep_cf_catch/widget/local_check_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

class LoginScreen extends StatefulWidget {
  static const String route = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SimpleAlertDialogMixin {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LoginBloc>(
          builder: (_) => LoginBloc(mixin: this),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<LocalBloc>(
          builder: (_) => LocalBloc(),
          dispose: (_, value) => value.dispose(),
        )
      ],
      child: Scaffold(
        body: Center(child: LoginForm()),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameTec = TextEditingController();
  final _passwordTec = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loginBloc = Provider.of<LoginBloc>(context);
    final localBloc = Provider.of<LocalBloc>(context);
    return Form(
        key: _formKey,
        child: Container(
          margin: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _usernameTec,
                  decoration: InputDecoration(border: OutlineInputBorder(), labelText: Strings.username),
                  validator: (value) {
                    if (value.isEmpty) {
                      return Strings.msgPleaseEnterUsername;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: PasswordFormField(_passwordTec),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  LocalCheckBox(localBloc: localBloc),
                  RaisedButton(
                      child: Text(Strings.login.toUpperCase()),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          if (await loginBloc.login(_usernameTec.text, _passwordTec.text)) {
                            Navigator.pushReplacementNamed(context, HomeScreen.route);
                          }
                        }
                      }),
                ],
              ),
            ],
          ),
        ));
  }
}

class PasswordFormField extends StatefulWidget {
  final passwordTec;

  PasswordFormField(this.passwordTec);

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  var _visible = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.passwordTec,
      obscureText: _visible,
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: Strings.password,
          suffixIcon: IconButton(
              icon: Icon(_visible ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _visible = !_visible;
                });
              })),
      validator: (value) {
        if (value.isEmpty) {
          return Strings.msgPleaseEnterPassword;
        }
      },
    );
  }
}