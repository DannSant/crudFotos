import 'dart:async';

import 'package:formularios_bloc/src/bloc/validators.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc with Validators{
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();

  //Obtener el ultimo valor ingresado
  String get email => _emailController.value;
  String get password => _passwordController.value;

  //Recuperar datos del Stream
  Stream<String> get emailStream =>_emailController.stream.transform(validarEmail);
  Stream<String> get passwordStream =>_passwordController.stream.transform(validarPassword);
  Stream<bool> get formValidStream => Observable.combineLatest2(emailStream, passwordStream, (e,p) =>true);

  //Insertar valores al stream
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  dispose(){
    _emailController?.close();
    _passwordController?.close();
  }
}