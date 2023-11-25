import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../model/ModelProduits.dart';
import '../model/ModelVariants.dart';
import '../scoped/Mains.dart';
import 'package:get/get.dart';
import 'package:elegant_notification/elegant_notification.dart';
import '../composants/historiques.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// ignore: must_be_immutable
class AllCategoriesPage extends StatefulWidget {
  Function setpartie;
  mainsScoped mains;
  AllCategoriesPage(this.setpartie, this.mains);
  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  Random _random = Random();
  @override
  void initState() {
    super.initState();
    widget.mains.fetchallergies();
    widget.mains.fetchvariants();
    widget.mains.fetchpayement();
    widget.mains.fetchinfos();
    setState(() {
      allergies = widget.mains.getallergiesdb;
      _selectedChips =
          List.generate(widget.mains.getallergiesdb.length, (index) => false);
      imagepromo = widget.mains.getimagespromo[
          _random.nextInt(widget.mains.getimagespromo.length)]['link'];
      categorieselectionnee = widget.mains.getmescategories.isEmpty
          ? 1
          : widget.mains.getcategorieschoisie;
    });
  }

  static final customcachemanager = CacheManager(Config(
      "tablettecacheallcategorie",
      stalePeriod: Duration(days: 7),
      maxNrOfCacheObjects: 500));
  String formatTime() {
    DateTime currentDate = DateTime.now();
    // Utilisation de la bibliothèque intl pour formater l'heure
    return DateFormat('HH:mm').format(currentDate);
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
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];

    String dayOfWeek = daysOfWeek[currentDate.weekday - 1];
    String month = months[currentDate.month - 1];

    String formattedDate =
        '$dayOfWeek ${currentDate.day} $month ${currentDate.year}';
    return formattedDate;
  }

  bool affichehistorique = false;
  bool afficherallergene = false;
  List<dynamic> allergies = [
    "Arachides",
    "Lait",
    "Blé",
    "Fruits à coque",
    "Soja",
    "Œufs",
    "Poisson",
    "Crustacés",
    "Mollusques",
    "Sésame",
    "Sulfites",
    "tomate",
    "pomme",
    "oignon",
    "aie",
    "piment",
    "autre",
  ];

  List<Map<String, dynamic>> _groupedVariants(
      List<dynamic> variants, plat, String message) {
    final groupedElements = <Map<String, dynamic>>[];

    for (final variant in variants) {
      if (variant.product_id_index ==
              widget.mains.getmonpanier.plats.indexOf(plat).toString() &&
          variant.nom != "rien" &&
          variant.message == message) {
        final existingElementIndex = groupedElements.indexWhere(
            (groupedElement) => groupedElement['nom'] == variant.nom);

        if (existingElementIndex != -1) {
          groupedElements[existingElementIndex]['count']++;
        } else {
          groupedElements.add({'nom': variant.nom, 'count': 1});
        }
      }
    }

    return groupedElements;
  }

  bool afficheroptionnotes = false;
  List allergiesajoutes = [];
  List<bool> _selectedChips = List.generate(17, (index) => false);
  void _showNoteDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
                child: Container(
              height: allergies.length < 1
                  ? MediaQuery.of(context).size.height * 0.8 / 3
                  : MediaQuery.of(context).size.height * 1.4 / 3,
              padding: EdgeInsets.all(MediaQuery.of(context).size.width / 100),
              width: MediaQuery.of(context).size.width * 2 / 3,
              child: Stack(
                children: [
                  ListView(
                    //  mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Center(
                        child: Text(
                          "Tableau d'allergenes".tr.toUpperCase(),
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width / 25),
                        ),
                      ),
                      allergies.length < 1
                          ? Center()
                          : Center(
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height / 4.5,
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.height / 50),
                                width:
                                    MediaQuery.of(context).size.width * 2 / 3,
                                //  color: Colors.green,
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    alignment: WrapAlignment
                                        .start, // Alignez les puces à gauche
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    runSpacing:
                                        MediaQuery.of(context).size.height /
                                            120,
                                    spacing:
                                        MediaQuery.of(context).size.height /
                                            120,
                                    children: allergies
                                        .asMap()
                                        .map((index, e) => MapEntry(
                                              index,
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedChips[index] =
                                                        !_selectedChips[index];
                                                  });

                                                  final data = allergies[index];

                                                  if (allergiesajoutes
                                                      .contains(data)) {
                                                    print(
                                                        "Retirer l'élément : $data");
                                                    allergiesajoutes
                                                        .remove(data);
                                                    print("allergies = " +
                                                        allergiesajoutes
                                                            .toString());
                                                  } else {
                                                    print(
                                                        "Ajouter l'élément : $data");
                                                    allergiesajoutes.add(data);
                                                    print("allergies = " +
                                                        allergiesajoutes
                                                            .toString());
                                                  }

                                                  //   widget.mains.ajouterallergies(
                                                  //       widget.id,
                                                  //       allergies[index]
                                                  //           .toString());
                                                },
                                                child: Chip(
                                                  labelStyle: TextStyle(
                                                      color: !_selectedChips[
                                                              index]
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Colors.white,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              80),
                                                  labelPadding: EdgeInsets.all(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          200),
                                                  backgroundColor:
                                                      _selectedChips[index]
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Colors.grey
                                                              .withOpacity(0.7),
                                                  avatar: CircleAvatar(
                                                    backgroundColor:
                                                        !_selectedChips[index]
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : Colors.white,
                                                    child: Text(
                                                      e
                                                          .toString()
                                                          .substring(0, 1)
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: _selectedChips[
                                                                  index]
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : Colors.white,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              80),
                                                    ),
                                                  ),
                                                  label: Text(e),
                                                ),
                                              ),
                                            ))
                                        .values
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                      Container(
                        margin: EdgeInsets.all(
                          MediaQuery.of(context).size.height / 150,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width / 80,
                          ),
                        ),
                        child: Center(
                          child: TextFormField(
                            initialValue: note,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: MediaQuery.of(context).size.width / 35,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            onChanged: (value) {
                              setState(() {
                                note = value;
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: "ajouter vos allergies".tr,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width * 2 / 3,
                          //   color: Colors.red,
                          child: Row(
                            mainAxisAlignment: note == ""
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.height /
                                          50,
                                      right:
                                          MediaQuery.of(context).size.height /
                                              50),
                                  margin: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width /
                                          50),
                                  width: MediaQuery.of(context).size.width / 4,
                                  height:
                                      MediaQuery.of(context).size.height / 25,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width:
                                            MediaQuery.of(context).size.height /
                                                200,
                                        color: Theme.of(context).primaryColor),
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.height /
                                            70),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "fermer".tr,
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              50,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              note.isEmpty
                                  ? Center()
                                  : GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          allergiesajoutes.add(note.toString());
                                          allergies.add(note);
                                          _selectedChips.add(true);
                                          note = "";
                                        });
                                        //      EasyLoading.showSuccess(
                                        //       "allergies ajoutees".tr);

                                        print("apres ajout on a " +
                                            allergiesajoutes.toString());
                                        //    widget.mains.addallergies(note);
                                        //  Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                50,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                50),
                                        margin: EdgeInsets.only(
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                50),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                4,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                25,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  200,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          borderRadius: BorderRadius.circular(
                                              MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  70),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "valider".tr,
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    50,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          )),
                    ],
                  )
                ],
              ),
            ));
          },
        );
      },
    );
  }

  String note = "";
  bool activeralergene = true;
  bool afficherlangue = false;
  int categorieselectionnee = 1;
  List allergie = [];
  String typevariant = "";
  bool isselect = false;
  String typevariantlimit = "1";
  int typevariantencours = 0;
  int typevariantrequired = 0;
  Map produitselectionne = {"name": "", "image": ""};
  bool affichepanier = false;
  List variantselectionne = [
    {"name": "rien", "price": "00.00", "message": "", "id": ""}
  ];
  List variantselectionne2 = [];
  int countUniqueMessages(List list) {
    Set<String> uniqueMessages = Set<String>();

    for (var item in list) {
      String message = item["message"];
      uniqueMessages.add(message);
    }

    return uniqueMessages.length;
  }

  String imagepromo = "";
  afficheallergenes(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(child: ScopedModelDescendant<mainsScoped>(
              builder: (context, child, model) {
                return Container(
                  height: MediaQuery.of(context).size.height / 2,
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width / 100),
                  width: MediaQuery.of(context).size.width * 2 / 3,
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Tableau d'allergenes".tr,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width / 50),
                          ),
                          Center(
                            child: Container(
                              height: MediaQuery.of(context).size.height / 3,
                              width: MediaQuery.of(context).size.width * 2 / 3,
                              child: Wrap(
                                runSpacing: 20,
                                spacing: 20,
                                children: <Widget>[...widget.mains.getallergies]
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final e = entry.value;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedChips[index] =
                                            !_selectedChips[index];
                                      });
                                    },
                                    child: Chip(
                                      labelStyle: TextStyle(
                                        color: !_selectedChips[index]
                                            ? Theme.of(context).primaryColor
                                            : Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                45,
                                      ),
                                      labelPadding: EdgeInsets.all(
                                          MediaQuery.of(context).size.height /
                                              80),
                                      backgroundColor: _selectedChips[index]
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey.withOpacity(0.7),
                                      avatar: CircleAvatar(
                                        backgroundColor: !_selectedChips[index]
                                            ? Theme.of(context).primaryColor
                                            : Colors.white,
                                        child: Text(
                                          e
                                              .toString()
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: _selectedChips[index]
                                                ? Theme.of(context).primaryColor
                                                : Colors.white,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                45,
                                          ),
                                        ),
                                      ),
                                      label: Text(e.toString()),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "fermer".tr.toUpperCase(),
                                style: TextStyle(),
                              ))
                        ],
                      )
                    ],
                  ),
                );
              },
            ));
          },
        );
      },
    );
  }

  void affichagedetail(context, e, sansmessage) {
    setState(() {
      afficherlangue = false;
      typevariant = "";
      typevariantlimit = "1";
      typevariantencours = 0;
      typevariantrequired = 0;
      affichepanier = false;
      variantselectionne = [
        {"name": "rien", "price": "00.00", "message": "", "id": ""}
      ];
      variantselectionne2 = [];
    });
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
                child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width * 3.9 / 5,
              margin: EdgeInsets.all(MediaQuery.of(context).size.width / 100),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/fleche.jpg"),
                      opacity: 0.03,
                      fit: BoxFit.cover)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 4,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          //       color: Colors.blue,
                          image: DecorationImage(
                              fit: BoxFit.contain,
                              image: CachedNetworkImageProvider(
                                  e.image.toString(),
                                  cacheManager: customcachemanager))),
                      child: Stack(
                        children: [
                          Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Theme.of(context).primaryColor,
                                  size: MediaQuery.of(context).size.height / 15,
                                ),
                              ))
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width / 50),
                      //   color: Colors.yellow,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.name.toString().toUpperCase(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 60),
                              ),
                              Text(
                                "${(1 * double.parse(e.price) + variantselectionne2.fold(00.00, (sum, elementss) => sum + double.parse(elementss['price']))).toStringAsFixed(2)} €",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 60),
                              )
                            ],
                          ),
                          Center(
                            child: Text(
                              e.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 100),
                            ),
                          )
                        ],
                      ),
                    ),
                    !sansmessage
                        ? Text(
                            typevariant,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height / 20),
                          )
                        : Container(),
                    sansmessage
                        ? Container()
                        : Text(
                            "( $typevariantlimit" + "choix autorise".tr + ")",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height / 40),
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit,
                          color: Theme.of(context).primaryColor,
                          size: MediaQuery.of(context).size.height / 45,
                        ),
                        GestureDetector(
                          onTap: () {
                            _showNoteDialog(context);
                          },
                          child: Text("allergenes".tr,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50)),
                        ),
                      ],
                    ),
                    sansmessage
                        ? Container()
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 4,
                            // color: Colors.red,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height / 5,
                                  width: MediaQuery.of(context).size.width *
                                      1.5 /
                                      2,
                                  //   color: Colors.yellow,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: widget.mains.gettableauvariant
                                        .where((es) =>
                                            es.product_id == e.id &&
                                            es.message == typevariant)
                                        .map<Widget>(
                                            (variant) => GestureDetector(
                                                  onTap: () {
                                                    int count =
                                                        variantselectionne2
                                                            .where((element) =>
                                                                element[
                                                                    "message"] ==
                                                                typevariant)
                                                            .length;

                                                    if (count <
                                                        int.parse(
                                                            typevariantlimit)) {
                                                      print("travail");
                                                      if (variantselectionne2
                                                              .where((element) =>
                                                                  element["message"] ==
                                                                      typevariant &&
                                                                  element["id"] ==
                                                                      variant
                                                                          .id)
                                                              .length ==
                                                          1) {
                                                        print(
                                                            "rajout de lelement " +
                                                                variant.nom);
                                                        setState(() {
                                                          variantselectionne2
                                                              .add({
                                                            "id": variant.id,
                                                            "name": variant.nom,
                                                            "price": variant
                                                                .price
                                                                .toString(),
                                                            "message":
                                                                typevariant
                                                          });
                                                        });
                                                        // si c'est le dernier element
                                                        if (variantselectionne2
                                                                    .where((element) =>
                                                                        element[
                                                                            "message"] ==
                                                                        typevariant)
                                                                    .length +
                                                                1 >=
                                                            int.parse(
                                                                typevariantlimit)) {
                                                          print("suivant");

                                                          List tableau = widget
                                                              .mains.variantList
                                                              .where((ed) =>
                                                                  ed['productid'] ==
                                                                  e.id.toString())
                                                              .toList();
                                                          setState(() {
                                                            typevariantlimit =
                                                                tableau.elementAt(
                                                                    1)["limit"];
                                                            typevariant = tableau
                                                                    .elementAt(
                                                                        1)[
                                                                "message"];
                                                            typevariantrequired =
                                                                int.parse(tableau
                                                                        .elementAt(
                                                                            1)[
                                                                    'isrequired']);
                                                          });
                                                        }
                                                      } else {
                                                        print("kkfk");
                                                        setState(() {
                                                          variantselectionne2
                                                              .add({
                                                            "id": variant.id,
                                                            "name": variant.nom,
                                                            "price": variant
                                                                .price
                                                                .toString(),
                                                            "message":
                                                                typevariant
                                                          });
                                                        });
                                                        if (variantselectionne2
                                                                .where((element) =>
                                                                    element[
                                                                        "message"] ==
                                                                    typevariant)
                                                                .length ==
                                                            int.parse(
                                                                typevariantlimit)) {
                                                          print("net ici avec count " +
                                                              variantselectionne2
                                                                  .where((element) =>
                                                                      element[
                                                                          "message"] ==
                                                                      typevariant)
                                                                  .length
                                                                  .toString() +
                                                              " et la limite est  " +
                                                              typevariantlimit);

                                                          List tableau = widget
                                                              .mains.variantList
                                                              .where((ed) =>
                                                                  ed['productid'] ==
                                                                  e.id.toString())
                                                              .toList();

                                                          int monindex = tableau
                                                              .indexWhere((eq) =>
                                                                  eq['message'] ==
                                                                  typevariant);

                                                          print(
                                                              'monindex: $monindex');
                                                          print(
                                                              'tableau: $tableau');

                                                          if (tableau.length ==
                                                              2) {
                                                            print(
                                                                "il y a deux");
                                                            Timer(
                                                                Duration(
                                                                    milliseconds:
                                                                        400),
                                                                () {
                                                              setState(() {
                                                                typevariantlimit =
                                                                    tableau.elementAt(
                                                                            1)[
                                                                        "limit"];
                                                                typevariant = tableau
                                                                        .elementAt(
                                                                            1)[
                                                                    "message"];
                                                                typevariantrequired =
                                                                    int.parse(tableau
                                                                        .elementAt(
                                                                            1)['isrequired']);
                                                              });
                                                            });
                                                            print("le typevariantisrequired =" +
                                                                typevariantrequired
                                                                    .toString());
                                                          }

                                                          if (tableau.length >=
                                                              // ajouter +1
                                                              (monindex + 1)) {
                                                            print("l'index est " +
                                                                monindex
                                                                    .toString() +
                                                                " tableau contient " +
                                                                tableau
                                                                    .toString());
                                                            Timer(
                                                                Duration(
                                                                    milliseconds:
                                                                        400),
                                                                () {
                                                              setState(() {
                                                                typevariantlimit =
                                                                    tableau.elementAt(
                                                                        monindex +
                                                                            1)["limit"];
                                                                typevariant = tableau
                                                                    .elementAt(
                                                                        monindex +
                                                                            1)["message"];
                                                                typevariantrequired =
                                                                    int.parse(tableau.elementAt(
                                                                        monindex +
                                                                            1)['isrequired']);
                                                              });
                                                            });
                                                            print("le typevariantisrequired =" +
                                                                typevariantrequired
                                                                    .toString());
                                                          }
                                                        }
                                                      }
                                                    } else if (count ==
                                                        int.parse(
                                                            typevariantlimit)) {
                                                      print("c'est egal");
                                                      if (variantselectionne2
                                                              .where((element) =>
                                                                  element["message"] ==
                                                                      typevariant &&
                                                                  element["id"] ==
                                                                      e.id)
                                                              .length ==
                                                          1) {
                                                        print(
                                                            "il contient deja lelement");
                                                        setState(() {
                                                          variantselectionne2
                                                              .removeWhere((element) =>
                                                                  element["message"] ==
                                                                      typevariant &&
                                                                  element["id"] ==
                                                                      variant
                                                                          .id);
                                                        });
                                                      } else {
                                                        print(
                                                            "maintenant on fait kw");
                                                        List tableau = widget
                                                            .mains.variantList
                                                            .where((fe) =>
                                                                fe['productid'] ==
                                                                e.id.toString())
                                                            .toList();

                                                        int monindex = tableau
                                                            .indexWhere((e) =>
                                                                e['message'] ==
                                                                typevariant);
                                                        Timer(
                                                            Duration(
                                                                milliseconds:
                                                                    400), () {
                                                          variantselectionne2
                                                                      .where((element) =>
                                                                          element["message"] ==
                                                                              typevariant &&
                                                                          element["id"] ==
                                                                              variant.id)
                                                                      .length >
                                                                  0
                                                              ? setState(() {
                                                                  variantselectionne2.remove(variantselectionne2.firstWhere((element) =>
                                                                      element["message"] ==
                                                                          typevariant &&
                                                                      element["id"] ==
                                                                          variant
                                                                              .id));
                                                                  typevariantlimit =
                                                                      tableau.elementAt(
                                                                          monindex +
                                                                              1)["limit"];
                                                                  typevariant =
                                                                      tableau.elementAt(
                                                                          monindex +
                                                                              1)["message"];
                                                                  typevariantrequired =
                                                                      int.parse(tableau.elementAt(
                                                                          monindex +
                                                                              1)['isrequired']);
                                                                })
                                                              : setState(() {
                                                                  variantselectionne2.remove(variantselectionne2.firstWhere((element) =>
                                                                      element[
                                                                          "message"] ==
                                                                      typevariant));
                                                                  variantselectionne2
                                                                      .add({
                                                                    "id":
                                                                        variant
                                                                            .id,
                                                                    "name":
                                                                        variant
                                                                            .nom,
                                                                    "price": variant
                                                                        .price
                                                                        .toString(),
                                                                    "message":
                                                                        typevariant
                                                                  });
                                                                  typevariantlimit =
                                                                      tableau.elementAt(
                                                                          monindex +
                                                                              1)["limit"];
                                                                  typevariant =
                                                                      tableau.elementAt(
                                                                          monindex +
                                                                              1)["message"];
                                                                  typevariantrequired =
                                                                      int.parse(tableau.elementAt(
                                                                          monindex +
                                                                              1)['isrequired']);
                                                                });
                                                        });
                                                      }
                                                    }
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.all(
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                130),
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            6,
                                                        decoration: variantselectionne2
                                                                    .where((element) =>
                                                                        element["id"] == variant.id &&
                                                                        element["name"] ==
                                                                            variant
                                                                                .nom)
                                                                    .length >
                                                                0
                                                            ? BoxDecoration(
                                                                //         color: Colors
                                                                //     .greenAccent,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        MediaQuery.of(context).size.width /
                                                                            50),
                                                                border: Border.all(
                                                                    color: Theme.of(context)
                                                                        .primaryColor,
                                                                    width: MediaQuery.of(context).size.width /
                                                                        200))
                                                            : BoxDecoration(
                                                                //         color: Colors
                                                                //     .greenAccent,
                                                                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width / 50),
                                                                border: Border.all(color: const Color.fromARGB(108, 158, 158, 158), width: MediaQuery.of(context).size.width / 200)),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            CachedNetworkImage(
                                                              cacheManager:
                                                                  customcachemanager,
                                                              fadeInDuration:
                                                                  Duration(
                                                                      milliseconds:
                                                                          0),
                                                              fadeOutDuration:
                                                                  Duration(
                                                                      milliseconds:
                                                                          0),
                                                              imageUrl:
                                                                  variant.image,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  9,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  10,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                            Text(
                                                              variant.nom
                                                                  .toString()
                                                                  .toUpperCase(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      (variant.nom.toString().length >
                                                                              13
                                                                          ? 80
                                                                          : 50),
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            Text(
                                                              variant.price +
                                                                  " €"
                                                                      .toString()
                                                                      .toUpperCase(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      50,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      variantselectionne2
                                                                  .where((element) =>
                                                                      element[
                                                                          "id"] ==
                                                                      variant
                                                                          .id)
                                                                  .length <
                                                              1
                                                          ? Center()
                                                          : Positioned(
                                                              right: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  40,
                                                              top: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  40,
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    variantselectionne2.removeWhere((element) =>
                                                                        element[
                                                                            "id"] ==
                                                                        variant
                                                                            .id);
                                                                  });
                                                                },
                                                                child: Icon(
                                                                  Icons.delete,
                                                                  size: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      25,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                ),
                                                              )),
                                                      variantselectionne2
                                                                  .where((element) =>
                                                                      element[
                                                                          "id"] ==
                                                                      variant
                                                                          .id)
                                                                  .length <
                                                              1
                                                          ? Center()
                                                          : Positioned(
                                                              top: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  40,
                                                              left: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  40,
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    25,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    25,
                                                                decoration: BoxDecoration(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(MediaQuery.of(context)
                                                                            .size
                                                                            .height)),
                                                                child: Center(
                                                                  child: Text(
                                                                    variantselectionne2
                                                                        .where((element) =>
                                                                            element["id"] ==
                                                                            variant.id)
                                                                        .length
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.height /
                                                                                40),
                                                                  ),
                                                                ),
                                                              ))
                                                    ],
                                                  ),
                                                ))
                                        .toList(),
                                  ),
                                ),
                                //   Container(
                                //      width: MediaQuery.of(context).size.width / 20,
                                //     color: Colors.blue,
                                //    child: Icon(
                                //       Icons.arrow_forward_ios,
                                //      color: Theme.of(context).primaryColor,
                                //      size: MediaQuery.of(context).size.height / 9,
                                //    ),
                                //    ),
                              ],
                            ),
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        (typevariantrequired == 1)
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  print("bouton appuye");
                                  // continuer  ou commander
                                  if (widget.mains.getvariantList
                                          .where(
                                              (zz) => zz['productid'] == e.id)
                                          .toList()[widget.mains.getvariantList
                                              .where((zz) =>
                                                  zz['productid'] == e.id)
                                              .toList()
                                              .length -
                                          1]['message'] ==
                                      typevariant) {
                                    print("enregistrement de la commande");
                                    for (var i = 0;
                                        i < allergiesajoutes.length;
                                        i++) {
                                      widget.mains.ajouterallergies(
                                          e.id, allergiesajoutes[i].toString());
                                    }
                                    print("on a ajoute les allergies " +
                                        allergiesajoutes.toString());
                                    print("dans la bd c'est enregistre " +
                                        widget.mains.getallergies.toString());

                                    if (typevariant ==
                                        widget.mains.variantList
                                            .where((eee) =>
                                                eee['productid'] ==
                                                e.id.toString())
                                            .toList()[widget.mains.variantList
                                                .where((ef) =>
                                                    ef['productid'] ==
                                                    e.id.toString())
                                                .length -
                                            1]["message"]) {
                                      for (var i = 1; i < 1 + 1; i++) {
                                        widget.mains.addsolde(
                                            double.parse(e.price) +
                                                double.parse(
                                                    variantselectionne[0]
                                                        ['price']));
                                      }
                                      setState(() {
                                        variantselectionne2 = [];
                                      });

                                      ElegantNotification.success(
                                          title: Text(
                                            "Commande enregistree".tr,
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    40),
                                          ),
                                          description: Text(
                                            "votre commande a ete ajoutee avec success"
                                                .tr,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    52),
                                          )).show(context);
                                      Navigator.pop(context);
                                    } else {}
                                  } else {
                                    print("suivant");

                                    var variantList = widget
                                        .mains.getvariantList
                                        .where((zz) => zz['productid'] == e.id)
                                        .toList();
                                    var currentIndex = variantList.indexWhere(
                                        (zz) => zz['message'] == typevariant);
                                    print(variantList[currentIndex + 1]
                                        ['message']);
                                    if (currentIndex != -1) {
                                      // Vérifie si l'élément est trouvé dans la liste
                                      setState(() {
                                        typevariantrequired = int.parse(
                                            variantList[currentIndex + 1]
                                                    ['isrequired']
                                                .toString());
                                        typevariant =
                                            variantList[currentIndex + 1]
                                                ['message'];
                                      });
                                      print("le typevariantrequired =" +
                                          typevariantrequired.toString());
                                    } else {
                                      // Gérer le cas où l'élément n'est pas trouvé
                                      // Par exemple, vous pouvez définir un message par défaut ou laisser inchangée la valeur de typevariant.
                                    }
                                  }
                                },
                                child: Container(
                                  height: MediaQuery.of(context).size.height *
                                      1 /
                                      18,
                                  width:
                                      MediaQuery.of(context).size.width / 4.5,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.height /
                                              50),
                                      border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              200)),
                                  child: Center(
                                      child: Text(
                                    "non merci".tr,
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                60,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor),
                                  )),
                                ),
                              ),
                        GestureDetector(
                          onTap: sansmessage
                              ? () {
                                  print("commande simple");
                                  List tableau = widget.mains.variantList
                                      .where((es) =>
                                          es['productid'] == e.id.toString())
                                      .toList();

                                  int monindex = tableau.indexWhere(
                                      (es) => es['message'] == typevariant);
                                  print("enregistrement de index " +
                                      monindex.toString() +
                                      " tableau longueur " +
                                      tableau.length.toString());
                                  if (monindex + 1 == tableau.length) {
                                    print("enregistrement");
                                    if (variantselectionne2.isEmpty) {
                                      print("dkdkdkd");
                                      widget.mains.addsolde(
                                          double.parse(e.price.toString()));
                                      widget.mains.ajouterplats(
                                          ModelProduit(
                                              e.id,
                                              e.name,
                                              e.description,
                                              e.image.toString(),
                                              e.price,
                                              e.category_id,
                                              "1",
                                              [],
                                              true),
                                          (widget.mains.getmonpanier.plats
                                                      .isEmpty ||
                                                  widget.mains.getmonpanier
                                                          .plats
                                                          .firstWhere(
                                                              (ea) =>
                                                                  ea.id == e.id,
                                                              orElse: () =>
                                                                  null) ==
                                                      null)
                                              ? -1
                                              : widget.mains.getmonpanier.plats
                                                  .indexOf(widget
                                                      .mains.getmonpanier.plats
                                                      .firstWhere((ee) =>
                                                          ee.id == e.id)));
                                      setState(() {
                                        variantselectionne2 = [];
                                      });
                                      ElegantNotification.success(
                                          title: Text(
                                            "Commande enregistree".tr,
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    40),
                                          ),
                                          description: Text(
                                            "votre commande a ete ajoutee avec success"
                                                .tr,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    52),
                                          )).show(context);
                                      Navigator.pop(context);
                                    }
                                  }
                                }
                              : () {
                                  print("bouton appuye");
                                  // continuer  ou commander
                                  if (widget.mains.getvariantList
                                          .where(
                                              (zz) => zz['productid'] == e.id)
                                          .toList()[widget.mains.getvariantList
                                              .where((zz) =>
                                                  zz['productid'] == e.id)
                                              .toList()
                                              .length -
                                          1]['message'] ==
                                      typevariant) {
                                    print("enregistrement de la commande");
                                    for (var i = 0;
                                        i < allergiesajoutes.length;
                                        i++) {
                                      widget.mains.ajouterallergies(
                                          e.id, allergiesajoutes[i].toString());
                                    }
                                    print("on a ajoute les allergies " +
                                        allergiesajoutes.toString());
                                    print("dans la bd c'est enregistre " +
                                        widget.mains.getallergies.toString());

                                    if (typevariant ==
                                        widget.mains.variantList
                                            .where((eee) =>
                                                eee['productid'] ==
                                                e.id.toString())
                                            .toList()[widget.mains.variantList
                                                .where((ef) =>
                                                    ef['productid'] ==
                                                    e.id.toString())
                                                .length -
                                            1]["message"]) {
                                      for (var i = 1; i < 1 + 1; i++) {
                                        widget.mains.addsolde(
                                            double.parse(e.price) +
                                                double.parse(
                                                    variantselectionne[0]
                                                        ['price']));
                                      }
                                      widget.mains.ajouterplats(
                                          ModelProduit(
                                              e.id,
                                              e.name,
                                              e.description,
                                              e.image,
                                              e.price,
                                              e.category_id,
                                              "1",
                                              [],
                                              true),
                                          -1);
                                      variantselectionne2.length > 0
                                          ? variantselectionne2
                                              .forEach((variantselectionne) {
                                              print("hum");
                                              if (variantselectionne["name"] !=
                                                  "rien") {
                                                print("ajout du variant " +
                                                    variantselectionne["name"]);
                                                widget.mains.Ajoutervariants(
                                                    ModelVariants(
                                                        variantselectionne[
                                                            "id"],
                                                        e.id,
                                                        variantselectionne[
                                                            "name"],
                                                        variantselectionne[
                                                            "price"],
                                                        (widget
                                                                    .mains
                                                                    .getmonpanier
                                                                    .plats
                                                                    .length +
                                                                -1)
                                                            .toString(),
                                                        variantselectionne[
                                                                "image"]
                                                            .toString(),
                                                        variantselectionne[
                                                            "message"]));
                                              }
                                            })
                                          : null;
                                      setState(() {
                                        variantselectionne2 = [];
                                      });
                                      ElegantNotification.success(
                                          title: Text(
                                            "Commande enregistree".tr,
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    40),
                                          ),
                                          description: Text(
                                            "votre commande a ete ajoutee avec success"
                                                .tr,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    52),
                                          )).show(context);
                                      Navigator.pop(context);
                                    } else {}
                                  } else {
                                    print("suivant");

                                    var variantList = widget
                                        .mains.getvariantList
                                        .where((zz) => zz['productid'] == e.id)
                                        .toList();
                                    var currentIndex = variantList.indexWhere(
                                        (zz) => zz['message'] == typevariant);
                                    print(variantList[currentIndex + 1]
                                        ['message']);
                                    if (currentIndex != -1) {
                                      // Vérifie si l'élément est trouvé dans la liste
                                      setState(() {
                                        typevariantrequired = int.parse(
                                            variantList[currentIndex + 1]
                                                    ['isrequired']
                                                .toString());
                                        typevariant =
                                            variantList[currentIndex + 1]
                                                ['message'];
                                      });
                                      print("le typevariantrequired =" +
                                          typevariantrequired.toString());
                                    } else {
                                      // Gérer le cas où l'élément n'est pas trouvé
                                      // Par exemple, vous pouvez définir un message par défaut ou laisser inchangée la valeur de typevariant.
                                    }
                                  }
                                },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 1 / 18,
                            width: MediaQuery.of(context).size.width / 4.5,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.height / 50),
                                border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: MediaQuery.of(context).size.height /
                                        200)),
                            child: Center(
                              child: Text(
                                sansmessage
                                    ? "Commander".tr.toUpperCase()
                                    : "Confirmer votre choix".tr.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.height /
                                            60),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    sansmessage
                        ? Container()
                        : StepProgressIndicator(
                            totalSteps: widget.mains.getvariantList
                                .where((zz) => zz['productid'] == e.id)
                                .toList()
                                .length,
                            currentStep:
                                countUniqueMessages(variantselectionne2),
                            size: MediaQuery.of(context).size.width / 15,
                            selectedColor: Theme.of(context).primaryColor,
                            unselectedColor: Color.fromARGB(255, 94, 88, 88),
                            customStep: (index, color, _) => color ==
                                    Theme.of(context).primaryColor
                                ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        typevariantrequired = int.parse(widget
                                            .mains.getvariantList
                                            .where(
                                                (zz) => zz['productid'] == e.id)
                                            .toList()[index]['isrequired']
                                            .toString());
                                        typevariant = widget
                                            .mains.getvariantList
                                            .where(
                                                (zz) => zz['productid'] == e.id)
                                            .toList()[index]['message']
                                            .toString();
                                        typevariantlimit = widget
                                            .mains.getvariantList
                                            .where(
                                                (zz) => zz['productid'] == e.id)
                                            .toList()[index]['limit']
                                            .toString();
                                      });
                                      print("nouvelle limit " +
                                          typevariantlimit.toString());
                                    },
                                    child: Container(
                                      color: color,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            typevariant ==
                                                    widget.mains.getvariantList
                                                        .where((zz) =>
                                                            zz['productid'] ==
                                                            e.id)
                                                        .toList()[index]
                                                            ['message']
                                                        .toString()
                                                ? Icons.soup_kitchen
                                                : Icons.check,
                                            color: Colors.white,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                35,
                                          ),
                                          Text(
                                              widget.mains.getvariantList
                                                  .where((zz) =>
                                                      zz['productid'] == e.id)
                                                  .toList()[index]['message']
                                                  .toString(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          120))
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: color,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.remove,
                                          color: const Color.fromARGB(
                                              139, 158, 158, 158),
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              35,
                                        ),
                                        Text(
                                            widget.mains.getvariantList
                                                .where((zz) =>
                                                    zz['productid'] == e.id)
                                                .toList()[index]['message'],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    120))
                                      ],
                                    ),
                                  ),
                          )
                  ]),
            ));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<mainsScoped>(
      builder: (context, child, model) {
        return Stack(
          children: [
            Positioned(
              left: MediaQuery.of(context).size.width / 80,
              top: MediaQuery.of(context).size.height / 7,
              child: GestureDetector(
                onTap: () {
                  widget.setpartie(6);
                },
                child: Container(
                  height: MediaQuery.of(context).size.height / 9,
                  color: Colors.transparent,
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: MediaQuery.of(context).size.height / 8,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 9.2 / 10,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 5,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 5,
                          height: MediaQuery.of(context).size.height / 5,
                          // color: Colors.green,
                          child: CachedNetworkImage(
                            fadeInDuration: Duration(milliseconds: 0),
                            cacheManager: customcachemanager,
                            fadeOutDuration: Duration(milliseconds: 0),
                            imageUrl: model.getmaisondata[0].logo.toString(),
                            width: MediaQuery.of(context).size.width / 5,
                            height: MediaQuery.of(context).size.height / 5,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 4 / 5,
                          height: MediaQuery.of(context).size.height / 5,
                          //  color: Colors.yellow,
                          child: Column(
                            children: [
                              Container(
                                width:
                                    MediaQuery.of(context).size.width * 4 / 5,
                                height: MediaQuery.of(context).size.height / 10,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.7),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    !afficherallergene
                                        ? GestureDetector(
                                            onTap: activeralergene
                                                ? () {
                                                    _showNoteDialog(context);
                                                  }
                                                : null,
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  left: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      50),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  1 /
                                                  15,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              50),
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              200)),
                                              child: Center(
                                                child: Text(
                                                  "Allergies".tr.toUpperCase(),
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              45),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Center(),
                                    GestureDetector(
                                      onTap: () {
                                        ElegantNotification.info(
                                                title: Text(
                                                  "demande envoyee"
                                                      .tr
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              40),
                                                ),
                                                description: Text(
                                                    "le serveur arrive vers vous"
                                                        .tr,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            52)))
                                            .show(context);
                                      },
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                1 /
                                                15,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Icon(
                                                Icons.person,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    60,
                                              ),
                                              Text(
                                                "appeler un serveur"
                                                    .tr
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            40),
                                              ),
                                            ],
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
                                        height:
                                            MediaQuery.of(context).size.height *
                                                1 /
                                                15,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Icon(
                                                Icons.note_alt_sharp,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    60,
                                              ),
                                              Text(
                                                "demander l'addition"
                                                    .tr
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            40),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: model.getmonpanier.plats.length > 0
                                          ? () {
                                              model.fetchdernierecommande();
                                              setState(() {
                                                affichepanier = !affichepanier;
                                              });
                                            }
                                          : null,
                                      child: Container(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width /
                                                50),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Icon(
                                                Icons.shopping_basket_rounded,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    50,
                                              ),
                                              Text(
                                                model.getmonpanier.plats
                                                        .where((el) =>
                                                            el.isactive == true)
                                                        .length
                                                        .toString() +
                                                    " " +
                                                    "Produits".tr +
                                                    " ".toUpperCase() +
                                                    model.getsolde
                                                        .toStringAsFixed(2)
                                                        .toString() +
                                                    " €",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            40),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height / 10,
                                color: Theme.of(context).primaryColor,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: model.getmescategories
                                      .map<Widget>((e) => GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                categorieselectionnee =
                                                    int.parse(
                                                        e["id"].toString());
                                              });
                                            },
                                            child: Container(
                                              color: Colors.transparent,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  5,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  10,
                                              child: Center(
                                                child: Text(
                                                  e["name"].toUpperCase(),
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          categorieselectionnee ==
                                                                  int.parse(
                                                                      e['id'])
                                                              ? MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  50
                                                              : MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  100),
                                                ),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 3.6 / 5,
                    width: MediaQuery.of(context).size.width,
                    //  color: Colors.yellow,
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          height: MediaQuery.of(context).size.height * 3.6 / 5,
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 60),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context)
                                      .primaryColorLight
                                      .withOpacity(0.2),
                                  width:
                                      MediaQuery.of(context).size.height / 100),
                              image: DecorationImage(
                                  image: AssetImage("assets/images/fleche.jpg"),
                                  opacity: 0.05,
                                  fit: BoxFit.cover)),
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width / 50),
                          child: Stack(
                            children: [
                              ListView(
                                children: model.gettableauproduits
                                    .where((prod) =>
                                        prod.category_id.toString() ==
                                        categorieselectionnee.toString())
                                    .map<Widget>((e) => GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              produitselectionne = {
                                                "name": e.name,
                                                "image": e.image
                                              };
                                            });
                                            print("selection de " +
                                                e.name +
                                                " avec " +
                                                e.image);
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    50),
                                            color: produitselectionne["name"] ==
                                                    e.name
                                                ? Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.4)
                                                : null,
                                            child: Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    model.gettableauvariant
                                                                .where((es) =>
                                                                    es.product_id ==
                                                                        e.id &&
                                                                    es.message ==
                                                                        typevariant)
                                                                .length >
                                                            0
                                                        ? Center()
                                                        : model.getmonpanier
                                                                    .plats
                                                                    .where((zz) =>
                                                                        zz.id ==
                                                                            e
                                                                                .id &&
                                                                        zz.isactive ==
                                                                            true)
                                                                    .length >
                                                                0
                                                            ? GestureDetector(
                                                                onTap: model.getmonpanier
                                                                            .plats
                                                                            .where((zz) =>
                                                                                zz.id == e.id &&
                                                                                zz.isactive == true)
                                                                            .length >
                                                                        0
                                                                    ? () {
                                                                        widget.mains.Modifierquantity(
                                                                            model.getmonpanier.plats.indexWhere((idi) =>
                                                                                idi.id ==
                                                                                e.id),
                                                                            2,
                                                                            e.price);
                                                                      }
                                                                    : null,
                                                                child: Icon(
                                                                  Icons
                                                                      .remove_circle_outline,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  size: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      40,
                                                                ),
                                                              )
                                                            : Center(),
                                                    model.gettableauvariant
                                                                .where((es) =>
                                                                    es.product_id ==
                                                                        e.id &&
                                                                    es.message ==
                                                                        typevariant)
                                                                .length >
                                                            0
                                                        ? Center()
                                                        : model.getmonpanier
                                                                    .plats
                                                                    .where((zz) =>
                                                                        zz.id ==
                                                                            e
                                                                                .id &&
                                                                        zz.isactive ==
                                                                            true)
                                                                    .length >
                                                                0
                                                            ? Text(
                                                                model
                                                                    .getmonpanier
                                                                    .plats
                                                                    .where((zz) =>
                                                                        zz.id ==
                                                                            e
                                                                                .id &&
                                                                        zz.isactive ==
                                                                            true)
                                                                    .toList()[0]
                                                                    .quantity
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        45,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor),
                                                              )
                                                            : Center(),
                                                    GestureDetector(
                                                      onTap: model.gettableauvariant
                                                                  .where((es) =>
                                                                      es.product_id ==
                                                                      e.id)
                                                                  .length >
                                                              0
                                                          ? () {
                                                              typevariant = model
                                                                          .gettableauvariant
                                                                          .where((es) =>
                                                                              es.product_id == e.id &&
                                                                              es.message ==
                                                                                  typevariant)
                                                                          .length >
                                                                      0
                                                                  ? model
                                                                      .getvariantList
                                                                      .firstWhere(
                                                                          (zz) =>
                                                                              zz['productid'] ==
                                                                              e.id)[
                                                                          "message"]
                                                                      .toString()
                                                                  : "";
                                                              affichagedetail(
                                                                  context,
                                                                  e,
                                                                  model.gettableauvariant
                                                                              .where((es) => es.product_id == e.id)
                                                                              .length >
                                                                          0
                                                                      ? false
                                                                      : true);
                                                            }
                                                          : () {
                                                              print(
                                                                  "commande simple ");

                                                              List tableau = widget
                                                                  .mains
                                                                  .variantList
                                                                  .where((es) =>
                                                                      es['productid'] ==
                                                                      e.id.toString())
                                                                  .toList();

                                                              int monindex = tableau
                                                                  .indexWhere((es) =>
                                                                      es['message'] ==
                                                                      typevariant);
                                                              print("enregistrement de index " +
                                                                  monindex
                                                                      .toString() +
                                                                  " tableau longueur " +
                                                                  tableau.length
                                                                      .toString());
                                                              if (monindex +
                                                                      1 ==
                                                                  tableau
                                                                      .length) {
                                                                print(
                                                                    "enregistrement");
                                                                if (variantselectionne2
                                                                    .isEmpty) {
                                                                  print(
                                                                      "dkdkdkd");
                                                                  widget.mains.addsolde(
                                                                      double.parse(e
                                                                          .price
                                                                          .toString()));
                                                                  widget.mains.ajouterplats(
                                                                      ModelProduit(
                                                                          e.id,
                                                                          e
                                                                              .name,
                                                                          e
                                                                              .description,
                                                                          e.image
                                                                              .toString(),
                                                                          e
                                                                              .price,
                                                                          e
                                                                              .category_id,
                                                                          "1",
                                                                          [],
                                                                          true),
                                                                      (widget.mains.getmonpanier.plats.where((el) => el.isactive == true).isEmpty ||
                                                                              widget.mains.getmonpanier.plats.firstWhere((ea) => ea.id == e.id, orElse: () => null) ==
                                                                                  null)
                                                                          ? -1
                                                                          : widget
                                                                              .mains
                                                                              .getmonpanier
                                                                              .plats
                                                                              .indexOf(widget.mains.getmonpanier.plats.firstWhere((ee) => ee.id == e.id && ee.isactive == true)));
                                                                  ElegantNotification
                                                                      .success(
                                                                          title:
                                                                              Text(
                                                                            "Commande enregistree".tr,
                                                                            style: TextStyle(
                                                                                color: Colors.green,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: MediaQuery.of(context).size.height / 40),
                                                                          ),
                                                                          description:
                                                                              Text(
                                                                            "votre commande a ete ajoutee avec success".tr,
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height / 52),
                                                                          )).show(
                                                                      context);
                                                                }
                                                              }
                                                            },
                                                      child: Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        size: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            40,
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width: model.getmonpanier
                                                                      .plats
                                                                      .where((zz) =>
                                                                          zz.id == e.id &&
                                                                          zz.isactive ==
                                                                              true)
                                                                      .length >
                                                                  0
                                                              ? model.gettableauvariant
                                                                          .where((es) =>
                                                                              es.product_id ==
                                                                              e
                                                                                  .id)
                                                                          .length >
                                                                      0
                                                                  ? MediaQuery.of(context)
                                                                          .size
                                                                          .width /
                                                                      2.40
                                                                  : MediaQuery.of(context)
                                                                          .size
                                                                          .width /
                                                                      2.65
                                                              : MediaQuery.of(context)
                                                                      .size
                                                                      .width /
                                                                  2.40,
                                                          //     color: Colors.green,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                e.name
                                                                    .toString()
                                                                    .substring(
                                                                        0,
                                                                        e.name.length >
                                                                                30
                                                                            ? 30
                                                                            : e.name.length)
                                                                    .toUpperCase(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        50),
                                                              ),
                                                              Text(
                                                                e.price +
                                                                    " €"
                                                                        .toString()
                                                                        .toUpperCase(),
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        80),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          width: model.getmonpanier
                                                                      .plats
                                                                      .where((zz) =>
                                                                          zz.id ==
                                                                          e.id)
                                                                      .length >
                                                                  0
                                                              ? MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  2.65
                                                              : MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  2.40,
                                                          child: Text(
                                                            e.description
                                                                .toString()
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    90),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          height: MediaQuery.of(context).size.height * 3.6 / 5,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("assets/images/fleche.jpg"),
                                  opacity: 0.1,
                                  fit: BoxFit.cover)),
                          //  color: Color.fromARGB(255, 134, 178, 214),
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3,
                              height:
                                  MediaQuery.of(context).size.height * 3 / 5,
                              decoration: BoxDecoration(
                                  //  color: Colors.red,
                                  image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          produitselectionne["image"] == ""
                                              ? imagepromo.toString()
                                              : produitselectionne["image"]
                                                  .toString(),
                                          cacheManager: customcachemanager),
                                      fit: BoxFit.fill)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // affichage panier
            affichepanier == false
                ? Container()
                : Positioned(
                    top: MediaQuery.of(context).size.height / 8,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.height / 120),
                      height: MediaQuery.of(context).size.height * 2.4 / 3,
                      color: Theme.of(context).secondaryHeaderColor,
                      child: Column(
                        children: [
                          Text(
                            "${model.getmonpanier.plats.where((e) => e.isactive == true).length} ${"Produits".toUpperCase()}",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height / 40),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 22),
                            height:
                                MediaQuery.of(context).size.height * 1.8 / 3,
                            // color: Colors.green,
                            child: Stack(
                              children: [
                                ListView(
                                  children: widget.mains.getmonpanier.plats
                                      .where((el) => el.isactive == true)
                                      .map<Widget>((e) => Container(
                                            margin: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    60),
                                            color: Colors.grey.withOpacity(0.4),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      2.5 /
                                                      3,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        // color: Colors.yellow,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                              //     color: Colors.red,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  25,
                                                              child: Center(
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height /
                                                                          25,
                                                                      child:
                                                                          Text(
                                                                        e.name.substring(
                                                                            0,
                                                                            min<int>(28,
                                                                                e.name.length)), // Spécifie explicitement le type générique <int> pour T
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              MediaQuery.of(context).size.height / 30,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontFamily:
                                                                              'Poppins',
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              // color: Colors.blue,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  4.5,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Container(
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              MediaQuery.of(context).size.height / 30,
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              widget.mains.Modifierquantity(widget.mains.getmonpanier.plats.indexOf(e), 2, e.price);
                                                                            },
                                                                            child:
                                                                                Icon(
                                                                              Icons.remove_circle,
                                                                              color: Theme.of(context).primaryColor,
                                                                              size: MediaQuery.of(context).size.height / 30,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              MediaQuery.of(context).size.height / 20,
                                                                          padding:
                                                                              EdgeInsets.all(MediaQuery.of(context).size.height / 230),
                                                                          child:
                                                                              Center(
                                                                            child: Text(e.quantity.toString(),
                                                                                style: TextStyle(
                                                                                  fontSize: MediaQuery.of(context).size.height / 40,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontFamily: "Poppins",
                                                                                  color: Colors.black,
                                                                                )),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              MediaQuery.of(context).size.height / 25,
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              widget.mains.Modifierquantity(widget.mains.getmonpanier.plats.indexOf(e), 1, e.price);
                                                                            },
                                                                            child:
                                                                                Icon(
                                                                              Icons.add_circle_outlined,
                                                                              color: Theme.of(context).primaryColor,
                                                                              size: MediaQuery.of(context).size.height / 30,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    "${(int.parse(e.quantity) * double.parse(e.price) + (widget.mains.getmonpanier.variants.where((es) => es.product_id_index == widget.mains.getmonpanier.plats.indexOf(e).toString()).toList().isNotEmpty ? widget.mains.getmonpanier.variants.where((es) => es.product_id_index == widget.mains.getmonpanier.plats.indexOf(e).toString()).toList().map((variant) => double.parse(variant.price)).reduce((value, element) => value + element) : 0.0)).toStringAsFixed(2)} €",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.height /
                                                                                40,
                                                                        fontFamily:
                                                                            'Poppins',
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Theme.of(context)
                                                                            .primaryColor),
                                                                  ),
                                                                  Container(
                                                                    child: IconButton(
                                                                        onPressed: model.getmonpanier.plats.where((el) => el.isactive == true).length == 1
                                                                            ? () {
                                                                                (ElegantNotification.error(
                                                                                    title: Text(
                                                                                      "au moins une commande".tr.toUpperCase(),
                                                                                      style: TextStyle(fontSize: MediaQuery.of(context).size.height / 40, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                                                                                    ),
                                                                                    //   background: Theme.of(context).primaryColor,
                                                                                    description: Text(
                                                                                      "vous devez avoir au moins un element dans le panier".tr,
                                                                                      style: TextStyle(fontSize: MediaQuery.of(context).size.height / 50, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                                                                                    ))).show(context);
                                                                              }
                                                                            : () {
                                                                                widget.mains.retirerplat(e);
                                                                              },
                                                                        icon: Icon(
                                                                          Icons
                                                                              .delete,
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              128,
                                                                              125,
                                                                              125),
                                                                          size: MediaQuery.of(context).size.width /
                                                                              40,
                                                                        )),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2,
                                                            child: Text(
                                                              e.description,
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black38,
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      68),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      widget.mains.getmonpanier
                                                              .variants
                                                              .where((es) =>
                                                                  es.product_id_index ==
                                                                  widget
                                                                      .mains
                                                                      .getmonpanier
                                                                      .plats
                                                                      .indexOf(
                                                                          e)
                                                                      .toString())
                                                              .isEmpty
                                                          ? Container()
                                                          : Container(
                                                              // height: 50,
                                                              child: Column(
                                                                children: widget
                                                                    .mains
                                                                    .getmonpanier
                                                                    .variants
                                                                    .where((es) =>
                                                                        es.product_id_index ==
                                                                            widget.mains.getmonpanier.plats
                                                                                .indexOf(
                                                                                    e)
                                                                                .toString() &&
                                                                        es.nom !=
                                                                            "rien")
                                                                    .map((element) =>
                                                                        element
                                                                            .message)
                                                                    .toSet()
                                                                    .map<Widget>(
                                                                        (message) =>
                                                                            Column(
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      message,
                                                                                      style: TextStyle(fontSize: MediaQuery.of(context).size.height / 35, color: Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Container(
                                                                                  height: MediaQuery.of(context).size.height / 43,
                                                                                  child: ListView(
                                                                                    scrollDirection: Axis.horizontal,
                                                                                    children: _groupedVariants(model.getmonpanier.variants, e, message).map<Widget>((groupedElement) {
                                                                                      final nom = groupedElement['nom'] as String;
                                                                                      final count = groupedElement['count'] as int;

                                                                                      return Container(
                                                                                        padding: EdgeInsets.all(MediaQuery.of(context).size.width / 400),
                                                                                        height: MediaQuery.of(context).size.width / 35,
                                                                                        margin: EdgeInsets.only(right: MediaQuery.of(context).size.width / 100),
                                                                                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width / 100)),
                                                                                        child: Center(
                                                                                          child: Text(
                                                                                            '($count) $nom ',
                                                                                            style: TextStyle(
                                                                                              fontSize: MediaQuery.of(context).size.width / 100,
                                                                                              color: Colors.white,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    }).toList(),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ))
                                                                    .toList(),
                                                              ),
                                                            ),
                                                      model.getallergies
                                                                  .where((element) =>
                                                                      element[
                                                                          "produit"] ==
                                                                      e.id)
                                                                  .length >
                                                              0
                                                          ? Container(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  11,
                                                              //   color:
                                                              //       Colors.green,
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        "notes".tr.toUpperCase() +
                                                                            ": ",
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: MediaQuery.of(context).size.width / 50),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height /
                                                                        20,
                                                                    color: Colors
                                                                        .transparent,
                                                                    child: ListView(
                                                                        scrollDirection: Axis.horizontal,
                                                                        children: model.getallergies
                                                                            .where((element) => element["produit"] == e.id)
                                                                            .map<Widget>(
                                                                              (el) => Text(
                                                                                el["data"].toString() + ", ",
                                                                                textAlign: TextAlign.start,
                                                                                style: TextStyle(color: const Color.fromARGB(109, 0, 0, 0), fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width / 50),
                                                                              ),
                                                                            )
                                                                            .toList()),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : Container()
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                ),
                                affichehistorique == true &&
                                        model.getderniercommande.length > 0
                                    ? Positioned(
                                        right: 0,
                                        child: Historiques(() {
                                          setState(() {
                                            affichehistorique =
                                                !affichehistorique;
                                          });
                                        }))
                                    : Center(),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 6.5,
                            color: Colors.grey.withOpacity(0.4),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        1.1 /
                                        3,
                                    //color: Colors.red,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "nombre de couvertures"
                                                    .tr
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            45),
                                              ),
                                              Text(
                                                model.getmonpanier.plats
                                                    .where((el) =>
                                                        el.isactive == true)
                                                    .length
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            45),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "date commande"
                                                    .tr
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            45),
                                              ),
                                              Text(
                                                formatDate(),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            45),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "heure commande"
                                                    .tr
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            45),
                                              ),
                                              Text(
                                                formatTime(),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            45),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "table".tr.toUpperCase(),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            45),
                                              ),
                                              Text(
                                                model.gettable.toString(),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            45),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        1.8 /
                                        3,
                                    //      color: Colors.green,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  50,
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  50),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "total".tr.toUpperCase() +
                                                          " HT" +
                                                          ':'.tr.toUpperCase(),
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              45),
                                                    ),
                                                    Text(
                                                      (model.getsolde /
                                                                  (1 +
                                                                      (model.getchoix == 1
                                                                              ? 10
                                                                              : 5.5) /
                                                                          100))
                                                              .toStringAsFixed(
                                                                  2) +
                                                          " €",
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              45),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "total".tr.toUpperCase() +
                                                          " TVA 10%" +
                                                          ':'.tr.toUpperCase(),
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              45),
                                                    ),
                                                    Text(
                                                      (model.getsolde -
                                                                  (model.getsolde /
                                                                      (1 +
                                                                          (model.getchoix == 1 ? 10 : 5.5) /
                                                                              100)))
                                                              .toStringAsFixed(
                                                                  2) +
                                                          " €",
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              45),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "total".tr.toUpperCase() +
                                                          " TTC" +
                                                          ':'.tr.toUpperCase(),
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              45),
                                                    ),
                                                    Text(
                                                      model.getsolde
                                                              .toStringAsFixed(
                                                                  2) +
                                                          " €",
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              45),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              !affichehistorique &&
                                                      model.getderniercommande
                                                              .length >
                                                          0
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          affichehistorique =
                                                              !affichehistorique;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.only(
                                                            left: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                50,
                                                            right: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                50),
                                                        margin: EdgeInsets.only(
                                                            right: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                50),
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            9,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            25,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  200,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor),
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor,
                                                          borderRadius: BorderRadius
                                                              .circular(MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  70),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "historiques".tr,
                                                            style: TextStyle(
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    70,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Center(),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    affichepanier = false;
                                                    affichehistorique = false;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      left:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              50,
                                                      right:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              50),
                                                  margin: EdgeInsets.only(
                                                      right:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              50),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      9,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      25,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            200,
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                70),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "annuler".tr,
                                                      style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              50,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    affichepanier = false;
                                                  });
                                                  model.supprimercommandeprov(
                                                      model.gettable
                                                          .toString());
                                                  model.enregistrercommandeprov(
                                                      false);
                                                  ElegantNotification.info(
                                                          description: Text(
                                                              "Votre commande est enregistree. Merci de valider pour l'envoyer en cuisine"
                                                                  .tr))
                                                      .show(context);
                                                  //  widget.setpartie(3);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      left:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              50,
                                                      right:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              50),
                                                  margin: EdgeInsets.only(
                                                      right:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              50),
                                                  //   width: MediaQuery.of(context).size.width / 9,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      25,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                70),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "valider ma commande".tr,
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
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              !afficheroptionnotes
                                                  ? Center()
                                                  : GestureDetector(
                                                      onTap: () {
                                                        _showNoteDialog(
                                                            context);
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.only(
                                                            left: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                50,
                                                            right: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                50),
                                                        margin: EdgeInsets.only(
                                                            right: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                50),
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            9,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            25,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  200,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor),
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor,
                                                          borderRadius: BorderRadius
                                                              .circular(MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  70),
                                                        ),
                                                        child: Center(
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .calendar_month,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                size: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    35,
                                                              ),
                                                              Text(
                                                                "notes".tr,
                                                                style: TextStyle(
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        50,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
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
                                  ),
                                ]),
                          )
                        ],
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
