import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablette/pages/LoadingPage.dart';
import '../pages/Login.dart';
import './scoped/Mains.dart';
import 'Translations.dart';

Future<void> main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(MyApp());
  });
}

mainsScoped mains = mainsScoped();

var recuperationcouleur;
MaterialColor getColorFromHex() {
  mains.fetchData();

  final hexCode = mains.getmaisondata.isEmpty
      ? "808080"
      : mains.getmaisondata[0].color1.replaceAll('#', '');
  final intColor = int.parse('FF$hexCode', radix: 16);
  print(" le getmaisondata donne " + mains.getmaisondata.toString());
  print("mon getcolor renvoie " + hexCode.toString());
  recuperationcouleur = MaterialColor(
    intColor,
    <int, Color>{
      50: Color(intColor + 0x0D000000),
      100: Color(intColor + 0x1A000000),
      200: Color(intColor + 0x26000000),
      300: Color(intColor + 0x33000000),
      400: Color(intColor + 0x40000000),
      500: Color(intColor + 0x4D000000),
      600: Color(intColor + 0x59000000),
      700: Color(intColor + 0x66000000),
      800: Color(intColor + 0x73000000),
      900: Color(intColor + 0x80000000),
    },
  );
  return MaterialColor(
    intColor,
    <int, Color>{
      50: Color(intColor + 0x0D000000),
      100: Color(intColor + 0x1A000000),
      200: Color(intColor + 0x26000000),
      300: Color(intColor + 0x33000000),
      400: Color(intColor + 0x40000000),
      500: Color(intColor + 0x4D000000),
      600: Color(intColor + 0x59000000),
      700: Color(intColor + 0x66000000),
      800: Color(intColor + 0x73000000),
      900: Color(intColor + 0x80000000),
    },
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application. bool
  bool recharger = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(Duration(seconds: 5), () async {
      getColorFromHex();
      setState(() {
        recharger = !recharger;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: mains,
        child: GetMaterialApp(
          title: 'TABLETTE COMMANDE',
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          locale: Get.deviceLocale,
          fallbackLocale: const Locale('fr', 'FR'),
          theme: ThemeData(
            textTheme: TextTheme(
              bodyText1: TextStyle(
                  // fontFamily: 'Poppins',
                  ),
              headline1: TextStyle(
                //    fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            primarySwatch: mains.getmaisondata.isEmpty
                ? getColorFromHex()
                : getColorFromHex(),
            secondaryHeaderColor: Colors.white,
          ),
          home: MyHomePage(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool ipverifie = false;
  @override
  void initState() {
    super.initState();
    Timer(Duration(microseconds: 3), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? resto = prefs.getString('resto');
      String? license = prefs.getString("license");
      if (resto == null || license == null) {
        setState(() {
          ipverifie = false;
        });
      } else {
        setState(() {
          ipverifie = true;
        });
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: ScopedModelDescendant<mainsScoped>(
        builder: (context, child, model) {
          return ipverifie == true ? LoadingPage(model) : const LoginPage();
        },
      ),
    );
  }
}
