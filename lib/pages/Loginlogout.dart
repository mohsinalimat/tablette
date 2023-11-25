import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablette/scoped/Mains.dart';
import 'package:elegant_notification/elegant_notification.dart';

// ignore: must_be_immutable
class LoginLogoutPage extends StatefulWidget {
  Function setpartie;
  LoginLogoutPage(this.setpartie);
  @override
  State<LoginLogoutPage> createState() => _LoginLogoutPageState();
}

class _LoginLogoutPageState extends State<LoginLogoutPage> {
  String lien = "";
  int numero = 0;
  String password = "";
  bool isloading = false;
  bool sinscrire = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showErrors = false;
  String? validateEmail(String value) {
    if (sinscrire && value.isEmpty) {
      return "Veuillez entrer un email.";
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
        .hasMatch(value)) {
      return "Veuillez entrer un email valide.";
    }
    return null;
  }

  String? validatePhone(String value) {
    if (value.isEmpty) {
      return "Veuillez entrer un numéro de téléphone.";
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return "Veuillez entrer un mot de passe.";
    }
    return null;
  }

  bool uniquemettel = true;
  Widget build(BuildContext context) {
    return ScopedModelDescendant<mainsScoped>(
      builder: (context, child, model) {
        return Container(
            height: MediaQuery.of(context).size.height * 9.2 / 10,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight.withOpacity(0.2),
            ),
            child: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 15,
                  right: MediaQuery.of(context).size.width / 15,
                  top: MediaQuery.of(context).size.width / 30,
                  bottom: MediaQuery.of(context).size.width / 30),
              height: MediaQuery.of(context).size.height / 8,
              width: MediaQuery.of(context).size.width * 3 / 4,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.height / 20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        blurRadius: MediaQuery.of(context).size.height / 50)
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 30),
                    height: MediaQuery.of(context).size.height * 1 / 8,
                    width: MediaQuery.of(context).size.height * 1 / 8,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                model.getmaisondata[0].logo.toString()))),
                    //  color: Colors.red,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            print('1');
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String nom = prefs.getString("resto").toString();

                            setState(() {
                              sinscrire = !sinscrire;
                              lien = 'www.menupremium.fr/' +
                                  nom +
                                  "/fidelite/signup.html";
                            });
                          },
                          child: Text(
                            "s'inscrire".tr,
                            style: TextStyle(
                                color: sinscrire
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.withOpacity(0.5),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width / 50),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            print('2');
                            setState(() {
                              sinscrire = !sinscrire;
                            });
                          },
                          child: Text(
                            "connexion".tr,
                            style: TextStyle(
                                color: sinscrire
                                    ? Colors.grey.withOpacity(0.5)
                                    : Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width / 50),
                          ),
                        )
                      ],
                    ),
                  ),
                  sinscrire
                      ? Text(
                          "scanner le qrcode pour creer votre compte"
                              .tr
                              .toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.height / 35),
                        )
                      : Center(),
                  Container(
                    padding:
                        EdgeInsets.all(MediaQuery.of(context).size.height / 50),
                    height: sinscrire
                        ? MediaQuery.of(context).size.height / 4
                        : MediaQuery.of(context).size.height / 5,
                    width: MediaQuery.of(context).size.width / 3,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.height / 60),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              blurRadius:
                                  MediaQuery.of(context).size.width / 200),
                        ]),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          sinscrire
                              ? Expanded(
                                  child: Center(
                                  child: PrettyQr(
                                    typeNumber: null,
                                    size: MediaQuery.of(context).size.height /
                                        4.8,
                                    data: lien,
                                    errorCorrectLevel: QrErrorCorrectLevel.M,
                                    roundEdges: true,
                                  ),
                                ))
                              : Center(),
                          sinscrire
                              ? Center()
                              : Container(
                                  child: TextFormField(
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.height /
                                              60,
                                      color: Theme.of(context).primaryColor),
                                  controller: _phoneController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                80),
                                    labelStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                60),
                                    labelText:
                                        "numero de telephone".tr.toUpperCase(),
                                    icon: Icon(Icons.call),
                                    errorText: _showErrors
                                        ? validatePhone(_phoneController.text)
                                        : null,
                                  ),
                                  validator: (value) => validatePhone(value!),
                                )),
                          sinscrire
                              ? Center()
                              : uniquemettel
                                  ? Center()
                                  : Expanded(
                                      child: TextFormField(
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                60,
                                            color:
                                                Theme.of(context).primaryColor),
                                        controller: _passwordController,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          errorStyle: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          labelStyle: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  60),
                                          labelText:
                                              "mot de passe".tr.toUpperCase(),
                                          icon: Icon(Icons.lock),
                                          errorText: _showErrors
                                              ? validatePassword(
                                                  _passwordController.text)
                                              : null,
                                        ),
                                        validator: (value) =>
                                            validatePassword(value!),
                                      ),
                                    )
                        ],
                      ),
                    ),
                  ),
                  sinscrire
                      ? Text(
                          "en creant un compte, vous acceptez nos conditions d'utilisation et notre politique de confidentialite"
                              .tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width / 65),
                        )
                      : Center(),
                  Container(
                    //  color: Colors.yellow,
                    height: MediaQuery.of(context).size.width / 10,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        sinscrire
                            ? Center()
                            : GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    _showErrors = true;
                                  });
                                  if (_formKey.currentState!.validate()) {
                                    print("C'est ok pour numero " +
                                        _phoneController.text.toString());
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    if (prefs.getBool("tablelock") == null) {
                                      print("1");
                                      print("pas bloque");
                                      widget.setpartie(2);
                                      model.setchoix(1);
                                      model.fetchcategories();
                                      model.fetchProduits();
                                      model.fetchinfos();
                                    } else {
                                      print("2");
                                      sinscrire
                                          ? model
                                              .inscription(
                                                  _phoneController.text,
                                                  _passwordController.text
                                                      .toString(),
                                                  _emailController.text)
                                              .then((value) {
                                              setState(() {
                                                //    valeurcode = "";
                                                isloading = !isloading;
                                              });

                                              if (value == true) {
                                                Timer(Duration(seconds: 0), () {
                                                  setState(() {
                                                    //    valeurcode = "";
                                                    isloading = !isloading;
                                                  });
                                                });
                                                print("inscription reussie");
                                                ElegantNotification.success(
                                                    title: Text(
                                                      "bienvenue"
                                                          .tr
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    description: Text(
                                                      "compte cree avec success"
                                                          .tr,
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )).show(context);
                                                model.settable(
                                                    prefs.getInt("table"));
                                                widget.setpartie(2);
                                                model.setchoix(1);
                                                model.fetchcategories();
                                                model.fetchProduits();
                                                model.fetchinfos();
                                              } else {
                                                Timer(Duration(seconds: 0), () {
                                                  setState(() {
                                                    //    valeurcode = "";
                                                    isloading = !isloading;
                                                  });
                                                });
                                                ElegantNotification.error(
                                                        description: Text(
                                                            "echec de l'inscription"
                                                                .tr))
                                                    .show(context);
                                              }
                                            })
                                          : model
                                              .fetchlogin(_phoneController.text)
                                              .then((value) {
                                              if (model.getclient.isEmpty) {
                                                Timer(Duration(seconds: 0), () {
                                                  setState(() {
                                                    //    valeurcode = "";
                                                    isloading = !isloading;
                                                  });
                                                });
                                                print("compte non existant");
                                                ElegantNotification.error(
                                                    title: Text(
                                                      "incorrect".tr,
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    description: Text(
                                                      "compte non existant".tr,
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )).show(context);
                                              } else {
                                                if (model.getclient[0].state ==
                                                    "blocked") {
                                                  print("compte blocker");
                                                  ElegantNotification.info(
                                                      title: Text(
                                                        "verrouille".tr,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      description: Text(
                                                        "compte verrouille"
                                                            .tr
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )).show(context);
                                                  Timer(Duration(seconds: 2),
                                                      () {
                                                    model.effaceruser();
                                                  });
                                                } else {
                                                  model.setnomutilisateur(model
                                                      .getclient[0].username
                                                      .toString());
                                                  ElegantNotification.success(
                                                      title: Text(
                                                        "bienvenue".tr,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      description: Text(
                                                        "bienvenue".tr +
                                                            " " +
                                                            model.getclient[0]
                                                                .username
                                                                .toString()
                                                                .toUpperCase(),
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )).show(context);
                                                  print("compte existant");
                                                  model.settable(
                                                      prefs.getInt("table"));
                                                  widget.setpartie(2);
                                                  model.setchoix(1);
                                                  model.fetchcategories();
                                                  model.fetchProduits();
                                                  model.fetchinfos();
                                                }
                                              }
                                            });

                                      //     model.settable(prefs.getInt("table"));
                                      //    widget.setpartie(2);
                                      //    model.setchoix(1);
                                      //    model.fetchcategories();
                                      //    model.fetchProduits();
                                      //    model.fetchinfos();
                                    }
                                  }
                                },
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 20,
                                  width: MediaQuery.of(context).size.width / 5,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: Theme.of(context).primaryColor,
                                          blurRadius: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              200),
                                    ],
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.height),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              2.5 /
                                              15,
                                          // color: Colors.green,
                                          child: Center(
                                            child: Text(
                                              sinscrire
                                                  ? "enregistrer".tr
                                                  : "se connecter".tr,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          65),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              35,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              35,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      MediaQuery.of(context)
                                                          .size
                                                          .height),
                                              color: Colors.white),
                                          child: Center(
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  60,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        GestureDetector(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (prefs.getBool("tablelock") == null) {
                              print("pas bloque");
                              widget.setpartie(9);
                              model.setchoix(1);
                              model.fetchcategories();
                              model.fetchProduits();
                              model.fetchinfos();
                            } else {
                              model.settable(prefs.getInt("table"));
                              widget.setpartie(9);
                              model.setchoix(1);
                              model.fetchcategories();
                              model.fetchProduits();
                              model.fetchinfos();
                            }
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height / 20,
                            width: MediaQuery.of(context).size.width / 5,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Theme.of(context).primaryColorLight,
                                    blurRadius:
                                        MediaQuery.of(context).size.width /
                                            200),
                              ],
                              borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.height),
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    child: Center(
                                      child: Text(
                                        "continuer sans compte".tr,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                65),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }
}
