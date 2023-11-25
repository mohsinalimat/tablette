import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablette/scoped/Mains.dart';

class AvantCommencer extends StatefulWidget {
  Function setpartie;
  AvantCommencer(this.setpartie);

  @override
  State<AvantCommencer> createState() => _AvantCommencerState();
}

class _AvantCommencerState extends State<AvantCommencer> {
  String nom = "";
  @override
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
                    Center(
                      child: Text(
                        "quel est votre prenom".tr.toUpperCase() +
                            " ? " +
                            "pour la commande de votre table".tr.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.height / 35),
                      ),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width / 3,
                        color: Theme.of(context).primaryColorLight,
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              nom = value.toString();
                            });
                          },
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.height / 40,
                              color: Theme.of(context).primaryColor),
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height / 60),
                            labelText: "votre prenom".tr.toUpperCase() + " ?",
                            icon: Icon(Icons.call),
                          ),
                        )),
                    GestureDetector(
                      onTap: () async {
                        if (nom.isEmpty) {
                          ElegantNotification.error(
                                  description: Text(
                                      "veuillez entrer votre prenom"
                                          .tr
                                          .toUpperCase()))
                              .show(context);
                        } else {
                          model.setnomutilisateur(nom);
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (prefs.getBool("tablelock") == null) {
                            print("pas bloque");
                            widget.setpartie(2);
                            model.setchoix(1);
                            model.fetchcategories();
                            model.fetchProduits();
                            model.fetchinfos();
                          } else {
                            model.settable(prefs.getInt("table"));
                            widget.setpartie(2);
                            model.setchoix(1);
                            model.fetchcategories();
                            model.fetchProduits();
                            model.fetchinfos();
                          }
                        }
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height / 20,
                        width: MediaQuery.of(context).size.width / 5,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context).primaryColor,
                                blurRadius:
                                    MediaQuery.of(context).size.width / 200),
                          ],
                          borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.height),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width *
                                    2.5 /
                                    15,
                                // color: Colors.green,
                                child: Center(
                                  child: Text(
                                    "continuer".tr,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                65),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 35,
                                height: MediaQuery.of(context).size.width / 35,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.height),
                                    color: Colors.white),
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Theme.of(context).primaryColor,
                                    size:
                                        MediaQuery.of(context).size.width / 60,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )));
      },
    );
  }
}
