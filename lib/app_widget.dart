import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payflow/shared/models/user_model.dart';

import 'modules/barcode_scanner/barcode_scanner_page.dart';
import 'modules/home/home_page.dart';
import 'modules/insert_boleto/insert_boleto_page.dart';
import 'modules/login/login_page.dart';
import 'modules/splash/splash_page.dart';
import 'shared/themes/app_colors.dart';

class AppWidget extends StatelessWidget {
  AppWidget() {
    // Esse construtor trava em apenas duas opções de orientação em que o device fica em pé
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pay Flow',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: AppColors.primary,
      ),
      //home: LoginPage(),
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => SplashPage(),
        "/home": (context) => HomePage(
            user: ModalRoute.of(context)!.settings.arguments as UserModel),
        "/login": (context) => LoginPage(),
        "/barcode_scanner": (context) => BarcodeScannerPage(),
        "/insert_boleto": (context) => InsertBoletoPage(
              barcode: ModalRoute.of(context) != null
                  ? ModalRoute.of(context)!.settings.arguments.toString()
                  : null,
            )
      },
    );
  }
}
