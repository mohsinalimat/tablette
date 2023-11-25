import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../scoped/Mains.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class ChoixPersonnes extends StatefulWidget {
  Function setpartie;
  ChoixPersonnes(this.setpartie);

  @override
  State<ChoixPersonnes> createState() => _ChoixPersonnesState();
}

class _ChoixPersonnesState extends State<ChoixPersonnes> {
  String nbreplace = "1";
  int numerotable = 0;

  verification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.getBool("tablelock") == null ? (isexist = false) : (isexist = true);
    });
    print("la verification doe " + isexist.toString());
  }

  bool isloading = false;
  bool nepasafficher = true;
  int codesecurite = 0;
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
                                                        widget.setpartie(8);
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

  bool? isexist = false;
  Widget build(BuildContext context) {
    return ScopedModelDescendant<mainsScoped>(
      builder: (context, child, model) {
        return Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: CachedNetworkImageProvider(
                      model.getdatainfos[0]["background"].toString()),
                  opacity: 0.3,
                  fit: BoxFit.cover)),
          child: Center(
              child: Container(
            height: MediaQuery.of(context).size.height * 9.2 / 10,
            width: MediaQuery.of(context).size.width * 2.5 / 3,
            //     color: Colors.grey,

            child: Container(
                //   color: Color.fromARGB(255, 251, 236, 240).withOpacity(0.7),
                margin: EdgeInsets.all(MediaQuery.of(context).size.height / 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 9.2 / 35,
                      width: MediaQuery.of(context).size.width / 5,
                      // color: Colors.blue,
                      child: CachedNetworkImage(
                        fadeInDuration: Duration(milliseconds: 0),
                        fadeOutDuration: Duration(milliseconds: 0),
                        imageUrl: model.getmaisondata[0].logo.toString(),
                        width: MediaQuery.of(context).size.width / 5,
                        height: MediaQuery.of(context).size.height * 9.2 / 35,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text(
                      "vous êtes combien de personnes".tr + " ?",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      height: MediaQuery.of(context).size.height / 10,
                      //   color: Colors.blue,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ["1", "2", "3", "4", "5", "6", "7", "8"]
                            .map<Widget>((e) => GestureDetector(
                                  onTap: isexist!
                                      ? () {
                                          setState(() {
                                            nbreplace = e;
                                          });
                                          Timer(Duration(seconds: 2), () {
                                            widget.setpartie(6);
                                          });
                                        }
                                      : () {
                                          setState(() {
                                            nbreplace = e;
                                          });
                                        },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 20,
                                    height:
                                        MediaQuery.of(context).size.width / 20,
                                    decoration: BoxDecoration(
                                      color: nbreplace != e
                                          ? Theme.of(context).primaryColorDark
                                          : Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.height /
                                              100),
                                    ),
                                    child: Center(
                                      child: Text(
                                        e,
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                30,
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    //   isexist!
                    nepasafficher
                        ? Center()
                        : Container(
                            padding: EdgeInsets.all(0),
                            height: MediaQuery.of(context).size.height / 12,
                            width: MediaQuery.of(context).size.width * 1.35 / 6,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 50),
                                //  color: Colors.red,
                                border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: MediaQuery.of(context).size.width /
                                        300)),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    child: Center(
                                      child: TextField(
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        onChanged: (value) {
                                          setState(() {
                                            numerotable =
                                                int.parse(value.toString());
                                          });
                                        },
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                60,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold),
                                        keyboardType: TextInputType.number,
                                        //     obscureText: afficherlicense,
                                        decoration: InputDecoration(
                                            hintMaxLines: 1,
                                            hintStyle: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    40),
                                            hintText: "numero de table".tr,
                                            contentPadding: EdgeInsets.all(0),
                                            border: InputBorder.none),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.person,
                        size: MediaQuery.of(context).size.height / 30,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .primaryColor, // Couleur de fond du bouton
                        foregroundColor: Theme.of(context)
                            .secondaryHeaderColor, // Couleur du texte du bouton
                      ),
                      onPressed: () {
                        model.fetchTable();
                        model.fetchProduits();
                        model.fetchcategories();
                        widget.setpartie(6);
                        model.recuperationcommandeprov();
                        model.fetchinfos();
                        model
                            .setnombrepersonne(int.parse(nbreplace.toString()));
                        //   reglagetable(context);
                      },
                      label: Text(
                        "continuer".tr.toUpperCase(),
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 45,
                            color: Theme.of(context).secondaryHeaderColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
//isexist!
                    nepasafficher
                        ? Center()
                        : ElevatedButton.icon(
                            icon: Icon(
                              Icons.food_bank_outlined,
                              size: MediaQuery.of(context).size.height / 30,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .primaryColor, // Couleur de fond du bouton
                              foregroundColor: Theme.of(context)
                                  .secondaryHeaderColor, // Couleur du texte du bouton
                            ),
                            onPressed: numerotable == 0
                                ? () {
                                    ElegantNotification.info(
                                        title: Text(
                                          "Numero de table".tr,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        description: Text(
                                          "veuillez choisir le numero de table"
                                              .tr,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )).show(context);
                                  }
                                : () async {
                                    model.fetchcategories();
                                    widget.setpartie(6);
                                    model.settable(numerotable);
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setBool("tablelock", true);
                                    prefs.setInt("table", numerotable);
                                  },
                            label: Text(
                              "commencer".tr.toUpperCase(),
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                  ],
                )),
          )),
        );
      },
    );
  }
}
