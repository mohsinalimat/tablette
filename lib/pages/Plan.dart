import 'dart:async';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablette/scoped/Mains.dart';

import '../model/ModelTable.dart';

class PlanResto extends StatefulWidget {
  Function setpartie;
  PlanResto(this.setpartie);
  @override
  State<PlanResto> createState() => _PlanRestoState();
}

List<List<dynamic>> diviserListe(List<dynamic> liste) {
  print("recuperation table = " + liste.toString());
  List<List<dynamic>> result = [];
  for (int i = 0; i < liste.length; i += 4) {
    int end = i + 4;
    if (end > liste.length) {
      end = liste.length;
    }
    result.add(liste.sublist(i, end));
  }
  return result;
}

class _PlanRestoState extends State<PlanResto> {
  @override
  String matable = "";
  Widget build(BuildContext context) {
    return ScopedModelDescendant<mainsScoped>(
      builder: (context, child, model) {
        return Container(
          color: Colors.black,
          height: MediaQuery.of(context).size.height * 9.2 / 10,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Plan du restaurant".tr.toUpperCase(),
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height / 30),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 7 / 10,
                //  color: Colors.green,
                child: GridView.count(
                  crossAxisCount: 2,
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.height / 30),
                  mainAxisSpacing: MediaQuery.of(context).size.height / 10,
                  crossAxisSpacing: MediaQuery.of(context).size.height / 20,
                  scrollDirection: Axis.horizontal,
                  children: diviserListe(model.getmestables)
                      .map<Widget>((e) => Center(
                            child: GridView.count(
                              crossAxisCount: 2,
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.height / 30),
                              mainAxisSpacing:
                                  MediaQuery.of(context).size.height / 30,
                              crossAxisSpacing:
                                  MediaQuery.of(context).size.height / 40,
                              children: e
                                  .map<Widget>((el) => GestureDetector(
                                        onTap: () async {
                                          if (model.getsolde > 00) {
                                            await model.supprimercommandeprov(
                                                model.gettable.toString());
                                            await model
                                                .enregistrercommandeprov(false);
                                          }
                                          //
                                          setState(() {
                                            matable = el.numero.toString();
                                          });
                                          model.settable(
                                              int.parse(el.numero.toString()));
                                          ElegantNotification.success(
                                                  description: Text(
                                                      "table changee avec success"
                                                          .tr))
                                              .show(context);
                                          model.fetchdernierecommande();
                                          model.recuperationcommandeprov();
                                          model.fetchcategories();
                                          model.fetchinfos();

                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          prefs.setBool("tablelock", true);
                                          prefs.setInt("table",
                                              int.parse(el.numero.toString()));
                                          Timer(Duration(milliseconds: 600),
                                              () {
                                            widget.setpartie(6);
                                          });
                                        },
                                        child: model.gettable.toString() ==
                                                el.numero.toString()
                                            ? Badge(
                                                label: Center(
                                                  child: Icon(
                                                    Icons.home,
                                                    size: MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        60,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                child: Container(
                                                  color: el.etat == 1
                                                      ? Colors.blue
                                                      : (el.etat == 2
                                                          ? Colors.green
                                                          : Colors.red),
                                                  child: Center(
                                                      child: Text(
                                                    el.numero
                                                        .toString()
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            50),
                                                  )),
                                                ),
                                              )
                                            : Container(
                                                color: el.etat == 1
                                                    ? Colors.blue
                                                    : (el.etat == 2
                                                        ? Colors.green
                                                        : Colors.red),
                                                child: Center(
                                                    child: Text(
                                                  el.numero
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              50),
                                                )),
                                              ),
                                      ))
                                  .toList(),
                            ),
                          ))
                      .toList(),
                ),
              ),
              Container(
                //    width: MediaQuery.of(context).size.width / 2.2,
                //  color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ElegantNotification.info(
                                description: Text(
                                    "votre demande d'anniversaire est envoyee"
                                        .tr))
                            .show(context);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 5,
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height / 80),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Center(
                          child: Text(
                            "demande anniversaire".tr.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height / 50),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ElegantNotification.info(
                                description:
                                    Text("le serveur arrive vers vous".tr))
                            .show(context);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 5,
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height / 80),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Center(
                          child: Text(
                            "appeler un serveur".tr.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height / 50),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: model.getmonpanier.plats.length > 0
                          ? () {
                              model.fetchinfos();
                              model.fetchpayement();
                              print("demande de l'addition");
                              widget.setpartie(4);
                            }
                          : null,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 5,
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height / 80),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Center(
                          child: Text(
                            "demander l'addition".tr.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height / 50),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "une fois la commande terminee et payee , merci de cliquer sur les encarts rouges pour les fermer"
                    .tr
                    .toUpperCase(),
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height / 45),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    //   color: Colors.grey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 10,
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.height / 80),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                          ),
                          child: Center(
                            child: Text(
                              "libre".tr.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.height / 50),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 10,
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.height / 80),
                          decoration: BoxDecoration(
                            color: Colors.green,
                          ),
                          child: Center(
                            child: Text(
                              "en cours".tr.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.height / 50),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 10,
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.height / 80),
                          decoration: BoxDecoration(
                            color: Colors.red,
                          ),
                          child: Center(
                            child: Text(
                              "fermer".tr.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.height / 50),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2.2,
                    //  color: Colors.grey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 5,
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.height / 80),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                          ),
                          child: Center(
                            child: Text(
                              "demande urgente table".tr.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.height / 50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
