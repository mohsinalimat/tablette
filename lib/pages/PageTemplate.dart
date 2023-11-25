import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_flags/country_flags.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tablette/composants/BatteryIconWidget.dart';
import 'package:tablette/pages/Avantcommencer.dart';
import 'package:tablette/pages/Categories.dart';
import 'package:tablette/pages/Felicitation.dart';
import 'package:tablette/pages/Loginlogout.dart';
import 'package:tablette/pages/Payement.dart';
import 'package:tablette/scoped/Mains.dart';
import './Home.dart';
import '../pages/AllCategories.dart';
import '../pages/ChoixPersonne.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../pages/Plan.dart';

class PageTemplate extends StatefulWidget {
  @override
  State<PageTemplate> createState() => _PageTemplateState();
}

class _PageTemplateState extends State<PageTemplate> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  int partie = 7;
  setpartie(nbre) {
    setState(() {
      partie = nbre;
    });
  }

  String formatTime() {
    DateTime currentDate = DateTime.now();
    // Utilisation de la bibliothèque intl pour formater l'heure
    return DateFormat('HH:mm').format(currentDate);
  }

  int pourcentagebatterie = 0;
  moniconebattery() async {
    return BatteryIconWidget(int.parse(
        (await BatteryInfoPlugin().iosBatteryInfo)!.batteryLevel.toString()));
  }

  String formatDate() {
    DateTime currentDate = DateTime.now();
    final List<String> daysOfWeek = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];

    final List<String> months = [
      'jan',
      'fév',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'sept',
      'oct',
      'nov',
      'déc',
    ];

    String dayOfWeek = daysOfWeek[currentDate.weekday - 1];
    String month = months[currentDate.month - 1];

    String formattedDate =
        '$dayOfWeek ${currentDate.day} $month ${currentDate.year}';
    return formattedDate;
  }

  bool afficherlangue = false;
  DeviceOrientation _currentOrientation = DeviceOrientation.landscapeLeft;
  void _rotateScreen() {
    setState(() {
      if (_currentOrientation == DeviceOrientation.landscapeLeft) {
        _currentOrientation = DeviceOrientation.landscapeRight;
      } else {
        _currentOrientation = DeviceOrientation.landscapeLeft;
      }
      SystemChrome.setPreferredOrientations([_currentOrientation]);
    });
  }

  Stream<bool> wifiConnectionStream() async* {
    final connectivity = Connectivity();
    await for (var result in connectivity.onConnectivityChanged) {
      if (result == ConnectivityResult.wifi) {
        yield true; // WiFi connecté
      } else {
        yield false; // WiFi déconnecté
      }
    }
  }

  Stream<int> batteryStream() async* {
    yield int.parse((await BatteryInfoPlugin().androidBatteryInfo)!
        .batteryLevel
        .toString());
  }

  Stream<String> monhorloge() async* {
    DateTime currentDate = DateTime.now();
    currentDate = DateTime.now();
    // Utilisation de la bibliothèque intl pour formater l'heure
    yield DateFormat('HH:mm').format(currentDate).toString();
  }

  String valeurcle = "";
  bool afficherbuttonkey = true;
  bool afficherrefresh2 = false;
  String valeurcle2 = "";
  bool afficherbuttonfinal = false;
  int codesecurite = 0;
  bool isloading = false;
  bool isverifycode = false;
  bool loadingtable = false;
  int newtable = 0;
  reglagetable(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(child: ScopedModelDescendant<mainsScoped>(
              builder: (context, child, model) {
                return Container(
                    height: MediaQuery.of(context).size.height * 2.2 / 3,
                    width: MediaQuery.of(context).size.width * 2 / 3,
                    color:
                        Theme.of(context).secondaryHeaderColor.withOpacity(0.4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.height / 25),
                          height: MediaQuery.of(context).size.height * 8 / 35,
                          width: MediaQuery.of(context).size.width / 5,
                          // color: Colors.blue,
                          child: CachedNetworkImage(
                            fadeInDuration: Duration(milliseconds: 0),
                            fadeOutDuration: Duration(milliseconds: 0),
                            imageUrl: model.getmaisondata[0].logo.toString(),
                            //  width: MediaQuery.of(context).size.width / 5,
                            //  height: MediaQuery.of(context).size.height * 8 / 35,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          "code de securite".tr.toUpperCase(),
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.height / 25),
                        ),
                        isloading
                            ? CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                                strokeWidth:
                                    MediaQuery.of(context).size.width / 80,
                              )
                            : Text(
                                codesecurite == 0
                                    ? "*******"
                                    : codesecurite.toString(),
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.height /
                                            25),
                              ),
                        Container(
                            height: MediaQuery.of(context).size.height / 4,
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.5),
                            width: MediaQuery.of(context).size.width / 4,
                            child: GridView.count(
                              childAspectRatio: 2,
                              crossAxisCount: 3,
                              children: [
                                "1",
                                "2",
                                "3",
                                "4",
                                "5",
                                "6",
                                "7",
                                "8",
                                "9",
                                "<-",
                                "0",
                                "OK"
                              ]
                                  .map((e) => GestureDetector(
                                        onTap: e == "<-" || e == "OK"
                                            ? () {
                                                if (e == "<-") {
                                                  if (codesecurite
                                                          .toString()
                                                          .length <
                                                      2) {
                                                    setState(() {
                                                      codesecurite = 0;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      codesecurite = int.parse(
                                                          codesecurite
                                                              .toString()
                                                              .substring(
                                                                  0,
                                                                  codesecurite
                                                                          .toString()
                                                                          .length -
                                                                      1));
                                                    });
                                                  }
                                                } else {
                                                  print("test de " +
                                                      codesecurite.toString());
                                                  setState(() {
                                                    isloading = true;
                                                  });
                                                  model
                                                      .testtablee(codesecurite
                                                          .toString())
                                                      .then((value) {
                                                    if (value == true) {
                                                      print("cest ok");
                                                      setState(() {
                                                        isloading = false;
                                                        //   afficherbuttonfinal =
                                                        //      true;
                                                        // lancement de l'autre page
                                                        partie = 8;
                                                      });
                                                      Navigator.pop(context);
                                                    } else {
                                                      print("cest false");
                                                      setState(() {
                                                        isloading = false;
                                                        codesecurite = 0;
                                                      });
                                                      ElegantNotification.error(
                                                        description: Text(
                                                          "code incorrect".tr,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        title: Text(
                                                          "erreur"
                                                              .tr
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ).show(context);
                                                    }
                                                  });
                                                }
                                              }
                                            : () {
                                                print(e);
                                                setState(() {
                                                  codesecurite = int.parse(
                                                      codesecurite.toString() +
                                                          e.toString());
                                                });
                                              },
                                        child: Container(
                                          color: Colors.transparent,
                                          child: Center(
                                              child: Text(
                                            e,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    30),
                                          )),
                                        ),
                                      ))
                                  .toList(),
                            )),
                      ],
                    ));
              },
            ));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, iskeyboardvisible) {
      return Scaffold(body: ScopedModelDescendant<mainsScoped>(
        builder: (context, child, model) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                partie == 2 ? ChoixPersonnes(setpartie) : Container(),
                partie == 3 ? AllCategoriesPage(setpartie, model) : Container(),
                partie == 4 ? PayementPage(setpartie) : Center(),
                partie == 5 ? FelicitationPage(setpartie, model) : Center(),
                partie == 6 ? CategoriesPages(setpartie) : Center(),
                partie == 7 ? LoginLogoutPage(setpartie) : Center(),
                partie == 8 ? PlanResto(setpartie) : Center(),
                partie == 9 ? AvantCommencer(setpartie) : Center(),
                afficherlangue
                    ? AnimatedPositioned(
                        curve: Curves.easeIn,
                        duration: Duration(milliseconds: 300),
                        bottom: MediaQuery.of(context).size.height * 0.8 / 10,
                        right: MediaQuery.of(context).size.width / 150,
                        child: Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 70),
                          height: MediaQuery.of(context).size.height / 3.5,
                          width: MediaQuery.of(context).size.width / 14,
                          color: Theme.of(context).primaryColorLight,
                          child: ListView(
                            scrollDirection: Axis.vertical,
                            children: model.getlanguagesdata
                                .map<Widget>(
                                  (edd) => GestureDetector(
                                    onTap: model.getlanguesselectionne == edd
                                        ? null
                                        : () {
                                            model.setlangueselectionne(
                                                edd.toString());

                                            Get.updateLocale(
                                                Locale(edd, edd.toUpperCase()));
                                            setState(() {
                                              afficherlangue = false;
                                            });
                                          },
                                    child: Center(
                                      child: Container(
                                        //  color: Colors.yellow,
                                        margin: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                55),
                                        height:
                                            MediaQuery.of(context).size.height /
                                                18,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                19,

                                        child: CountryFlag.fromCountryCode(
                                          edd,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              10,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ))
                    : Container(),
                !iskeyboardvisible
                    ? Positioned(
                        bottom: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: Theme.of(context).primaryColor,
                          height: MediaQuery.of(context).size.height * 0.8 / 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                //color: Colors.green,
                                width: MediaQuery.of(context).size.width / 4.5,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timer_sharp,
                                          color: Colors.white,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.8 /
                                              20,
                                        ),
                                        StreamBuilder(
                                          stream: monhorloge(),
                                          builder: (context, snapshot) {
                                            return Text(
                                              snapshot.data.toString(),
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.8 /
                                                          30,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    Text(
                                      formatDate(),
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.8 /
                                              30,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                //  color: Colors.green,
                                width: MediaQuery.of(context).size.width / 5,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          model.restauration();
                                          Navigator.pushReplacement(context,
                                              MaterialPageRoute(
                                            builder: (context) {
                                              return HomePage(model);
                                            },
                                          ));
                                        },
                                        child: Icon(
                                          Icons.home,
                                          color: Colors.white,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.8 /
                                              13,
                                        )),
                                    GestureDetector(
                                      onTap: () {
                                        print("lancement de la rotation");
                                        _rotateScreen();
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.height /
                                                20,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                20,
                                        //  color: Colors.green,
                                        child: Center(
                                          child: Icon(
                                            Icons.screen_rotation,
                                            color: Colors.white,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                22,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              model.gettable == 0
                                  ? Container()
                                  : Container(
                                      //    color: Colors.green,
                                      width:
                                          MediaQuery.of(context).size.width / 5,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.table_bar,
                                            color: Colors.white,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.8 /
                                                20,
                                          ),
                                          Text(
                                            "table".tr +
                                                " " +
                                                model.gettable.toString(),
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.8 /
                                                    30,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                              Container(
                                //    color: Colors.green,
                                width: MediaQuery.of(context).size.width / 5,
                                child: Row(
                                  children: [
                                    StreamBuilder<int>(
                                      stream: batteryStream(),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data.toString() + "%",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  50),
                                        );
                                      },
                                    ),
                                    StreamBuilder<int>(
                                      stream: batteryStream(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          //final batteryState = snapshot.data!;
                                          final batteryIcon = BatteryIconWidget(
                                              int.parse(
                                                  snapshot.data.toString()));

                                          return batteryIcon;
                                        } else if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else {
                                          return Text(
                                              'Erreur lors de la récupération des données');
                                        }
                                      },
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        model.fetchTable();
                                        setState(() {
                                          afficherbuttonfinal = false;
                                          codesecurite = 0;
                                          isloading = false;
                                          isverifycode = false;
                                          loadingtable = false;
                                          newtable = 0;
                                        });
                                        reglagetable(context);
                                      },
                                      child: Icon(
                                        Icons.lock,
                                        color: Colors.white,
                                        size:
                                            MediaQuery.of(context).size.height *
                                                0.8 /
                                                20,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(
                                        MediaQuery.of(context).size.width / 300,
                                      ),
                                      width: MediaQuery.of(context).size.width /
                                          350,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.8 /
                                              20,
                                      color: Colors.white,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                          25,
                                      // color: Colors.green,
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              afficherlangue = !afficherlangue;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(
                                                MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    125),
                                            //  color: Colors.yellow,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                5,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,

                                            child: CountryFlag.fromCountryCode(
                                              model.getlanguesselectionne
                                                  .toString(),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Center()
              ],
            ),
          );
        },
      ));
    });
  }
}
