import 'package:flutter/material.dart';
import 'package:payflow/modules/home/home_page.dart';
import 'package:payflow/modules/login/login_page.dart';
import 'package:payflow/shared/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  UserModel? _user; // tem ? porque user permite ser nulo

  UserModel get user =>
      _user!; //com o ! garanto que só vou chamar depois que tiver logado, ou seja, não tá null

  void setUser(BuildContext context, UserModel? user) {
    if (user != null) {
      saveUser(user);
      _user = user;
      // Navigator.push redireciona para a página; O Navigator.pushReplacement substitui a tela
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage())); // não tem rota nomeada
      Navigator.pushReplacementNamed(
          context, "/home"); // navegação por rota nomeada
    } else {
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())); // não tem rota nomeada
      Navigator.pushReplacementNamed(
          context, "/login"); // navegação por rota nomeada
    }
  }

  // Future<void> saveUser(var user) async
  Future<void> saveUser(UserModel user) async {
    final instance = await SharedPreferences.getInstance();

    // await instance.setString("user", user);
    await instance.setString("user", user.toJson());
    return;
  }

  Future<void> currentUser(BuildContext context) async {
    final instance = await SharedPreferences.getInstance();
    await Future.delayed(Duration(seconds: 2));
    if (instance.containsKey("user")) {
      // final user = instance.get("user");
      final json = instance.get("user") as String;
      // setUser(context, UserModel.fromJson(user)); // enviando o user
      setUser(context,
          UserModel.fromJson(json)); // enviando o json que tem o usuario
      return;
    } else {
      setUser(context, null);
    }
  }
}
