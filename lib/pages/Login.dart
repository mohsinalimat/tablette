import 'dart:async';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablette/pages/LoadingPage.dart';
import '../scoped/Mains.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mac_address/mac_address.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

bool afficherlicense = false;
String adressip = "";
bool afficherbuttonlicense = false;
bool afficherbuttonfinal = false;
String valeurlicense = "";
bool afficherrefresh1 = false;
bool afficherrefresh2 = false;
bool afficherrefresh3 = false;

class _LoginPageState extends State<LoginPage> {
  bool afficherbuttonfinal2 = false;
  bool affichernumerotable = false;
  String mac = "mac initial";
  String macadress = "";
  String valeurtable = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      String platformVersion = await GetMac.macAddress;

      setState(() {
        macadress = platformVersion.toString();
      });

      print("L'adresse MAC de l'appareil est : $platformVersion");
    } on PlatformException catch (e) {
      print("Échec de l'obtention de l'adresse MAC de l'appareil : $e");
      setState(() {
        macadress = 'Échec de l\'obtention de l\'adresse MAC.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<mainsScoped>(builder: (context, child, model) {
      return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/fleche.jpg"),
                opacity: 0.1,
                fit: BoxFit.cover)),
        child: Row(children: [
          Container(
            // color: Color.fromARGB(255, 251, 236, 240).withOpacity(0.7),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width * 1.35 / 3,
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 15,
                bottom: MediaQuery.of(context).size.height / 15),
            child: Container(
                height: MediaQuery.of(context).size.height * 4 / 5,
                width: MediaQuery.of(context).size.width,
                color: Colors.grey.withOpacity(0.2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 10,
                      //      color: Colors.green,
                      child: Text(
                        "Bornecommande.fr",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.height / 25),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 15,
                      //   color: Colors.green,
                      child: Text(
                        "Configuration du terminal".toUpperCase(),
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.height / 25),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 2.5,
                      //  color: Colors.yellow,
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height / 15,
                            //    color: Colors.green,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(0),
                                  width: MediaQuery.of(context).size.width *
                                      1.35 /
                                      6,
                                  decoration: BoxDecoration(
                                      //  color: Colors.red,
                                      border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              300)),
                                  child: Center(
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          adressip = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                          hintStyle: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  60),
                                          hintText: "XXX.XXX.XXX.XXX",
                                          border: InputBorder.none),
                                    ),
                                  ),
                                ),
                                afficherbuttonlicense
                                    ? Container(
                                        margin: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                400,
                                            bottom: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                400),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1.35 /
                                                8,
                                        child: const Center(
                                            child: Icon(
                                          Icons.play_circle,
                                          color: Colors.green,
                                        )),
                                      )
                                    : (afficherrefresh1
                                        ? RefreshProgressIndicator()
                                        : GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                afficherrefresh1 = true;
                                              });
                                              model
                                                  .testconnexion(
                                                      adressip.toString())
                                                  .then((value) async {
                                                if (value == true) {
                                                  print(
                                                      "c'est ok suite sur le test de license");

                                                  setState(() {
                                                    afficherrefresh1 = false;
                                                    afficherbuttonlicense =
                                                        true;
                                                  });
                                                } else {
                                                  print("mauvais");
                                                  setState(() {
                                                    afficherrefresh1 = false;
                                                  });
                                                  ElegantNotification.error(
                                                      description: Text(
                                                    "address incorrect",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )).show(context);
                                                }
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  top: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      400,
                                                  bottom: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      400),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1.35 /
                                                  8,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              child: Center(
                                                child: Text(
                                                  'Tester',
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              50,
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ))
                              ],
                            ),
                          ),
                          afficherbuttonlicense
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height / 15,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(0),
                                        height:
                                            MediaQuery.of(context).size.height /
                                                15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1.35 /
                                                6,
                                        decoration: BoxDecoration(
                                            //  color: Colors.red,
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    300)),
                                        child: Center(
                                          child: TextField(
                                            onChanged: (value) {
                                              valeurlicense = value;
                                            },
                                            //  obscureText: afficherlicense,
                                            decoration: InputDecoration(
                                                hintStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            60),
                                                hintText: "NUMERO DE LICENSE",
                                                contentPadding:
                                                    EdgeInsets.all(0),
                                                border: InputBorder.none),
                                          ),
                                        ),
                                      ),
                                      afficherrefresh2
                                          ? RefreshProgressIndicator()
                                          : (afficherbuttonlicense &&
                                                  afficherbuttonfinal == false)
                                              ? GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      afficherrefresh2 = true;
                                                    });
                                                    model
                                                        .testlicense(
                                                            adressip.toString(),
                                                            valeurlicense)
                                                        .then((value) async {
                                                      if (value == true) {
                                                        print(
                                                            "c'est ok suite sur le final");
                                                        setState(() {
                                                          affichernumerotable =
                                                              true;
                                                          afficherbuttonfinal =
                                                              true;
                                                          afficherrefresh2 =
                                                              false;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          afficherrefresh2 =
                                                              false;
                                                        });
                                                        ElegantNotification
                                                            .error(
                                                                description:
                                                                    Text(
                                                          "Licence incorrect",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )).show(context);
                                                        print("mauvais");
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            400,
                                                        bottom: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            400),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            1.35 /
                                                            8,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    child: Center(
                                                      child: Text(
                                                        'Tester',
                                                        style: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                50,
                                                            color: Theme.of(
                                                                    context)
                                                                .secondaryHeaderColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : affichernumerotable == true
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                          top: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              400,
                                                          bottom: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              400),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              1.35 /
                                                              8,
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.play_circle,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    )
                                                  : Container()
                                    ],
                                  ),
                                )
                              : Center(),
                          affichernumerotable
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height / 15,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(0),
                                        height:
                                            MediaQuery.of(context).size.height /
                                                15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1.35 /
                                                6,
                                        decoration: BoxDecoration(
                                            //  color: Colors.red,
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    300)),
                                        child: Center(
                                          child: TextField(
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              valeurtable = value.toString();
                                            },
                                            //  obscureText: afficherlicense,
                                            decoration: InputDecoration(
                                                hintStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            60),
                                                hintText: "NUMERO DE TABLE",
                                                contentPadding:
                                                    EdgeInsets.all(0),
                                                border: InputBorder.none),
                                          ),
                                        ),
                                      ),
                                      afficherrefresh3
                                          ? RefreshProgressIndicator()
                                          : (affichernumerotable &&
                                                  afficherbuttonfinal2 == false)
                                              ? GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      afficherrefresh3 = true;
                                                    });
                                                    Timer(Duration(seconds: 2),
                                                        () {
                                                      setState(() {
                                                        afficherrefresh3 =
                                                            false;
                                                        afficherbuttonfinal2 =
                                                            true;
                                                      });
                                                    });
                                                    // enregistrement de la table
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            400,
                                                        bottom: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            400),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            1.35 /
                                                            8,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    child: Center(
                                                      child: Text(
                                                        'Enregistrer',
                                                        style: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                50,
                                                            color: Theme.of(
                                                                    context)
                                                                .secondaryHeaderColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : afficherbuttonfinal2 == true
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                          top: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              400,
                                                          bottom: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              400),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              1.35 /
                                                              8,
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.save,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    )
                                                  : Container()
                                    ],
                                  ),
                                )
                              : Center(),
                          Row(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height / 15,
                                width: MediaQuery.of(context).size.width *
                                    1.35 /
                                    6,
                                child: Center(
                                  child: Text(
                                    macadress.toString(),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                45),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                    //  color: Colors.red,
                                    border: Border.all(
                                        color: Theme.of(context).primaryColor,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                300)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    afficherbuttonfinal2
                        ? Container(
                            //   height: MediaQuery.of(context).size.width / 10,
                            //  color: Colors.green,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .primaryColor, // Couleur de fond du bouton
                                foregroundColor: Theme.of(context)
                                    .secondaryHeaderColor, // Couleur du texte du bouton
                              ),
                              onPressed: () async {
                                model.fetchData();
                                model.fetchinfos();
                                model.fetchlanguages();
                                model.fetchvideos();
                                model.fetchProduits();
                                model.fetchpromoimage();
                                model.fetchvariants();
                                model.settable(
                                    int.parse(valeurtable.toString()));
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool("tablelock", true);
                                prefs.setInt(
                                    "table", int.parse(valeurtable.toString()));

                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(
                                  builder: (context) {
                                    return LoadingPage(model);
                                  },
                                ));
                              },
                              child: Text(
                                "Commencer l'installation".toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Center()
                  ],
                )),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 1.65 / 3,
            //  color: Colors.indigo,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/backgroundlogin.jpg"),
                    fit: BoxFit.fill)),
          )
        ]),
      );
    });
  }
}
