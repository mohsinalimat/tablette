import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:get/get.dart';
import '../scoped/Mains.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// ignore: must_be_immutable
class PayementPage extends StatefulWidget {
  Function setpartie;
  PayementPage(this.setpartie);
  @override
  State<PayementPage> createState() => _PayementPageState();
}

class _PayementPageState extends State<PayementPage> {
  String choix = "";
  static final customcachemanager = CacheManager(Config("tablettecachepayement",
      stalePeriod: Duration(days: 7), maxNrOfCacheObjects: 10));
  List lesplats = [];
  List lesvariants = [];
  List lesallergies = [];
  String iddelatable = "";
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<mainsScoped>(
      builder: (context, child, model) {
        return Container(
          height: MediaQuery.of(context).size.height * 9.2 / 10,
          width: MediaQuery.of(context).size.width,
          // color: const Color.fromARGB(255, 207, 167, 47),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: CachedNetworkImageProvider(
                      model.getdatainfos[0]["background"].toString()),
                  opacity: 0.05,
                  fit: BoxFit.cover)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 9.2 / 35,
                width: MediaQuery.of(context).size.width / 3,
                //  color: Colors.blue,
                child: Image(
                  image: NetworkImage(model.getmaisondata[0].logo.toString()),
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.height * 9.2 / 35,
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                "comment voulez-vous regler l'addition".tr + " ?",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height / 25),
              ),
              Text(
                model.getsolde.toStringAsFixed(2).toString() + "€",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height / 25),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 2.6 / 3,
                  height: MediaQuery.of(context).size.height / 2.9,
                  //   color: Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //     scrollDirection: Axis.horizontal,
                    children: model.getlespayements
                        .map<Widget>((payement) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  lesplats = model.getmonpanier.plats
                                      .where((ee) => ee.isactive == true)
                                      .toList();
                                  lesvariants = model.getmonpanier.variants;
                                  lesallergies = model.getallergies;
                                  iddelatable = model.gettable.toString();
                                });
                                print(" PANIER = " +
                                    model.getmonpanier.plats.toString());
                                model
                                    .creerCommande(
                                        'sur place',
                                        "En cours",
                                        payement.nom.toString(),
                                        model.getnomutilisateur.toString(),
                                        model.getnbrepersonne.toString())
                                    .then((value) {
                                  if (value == true) {
                                    print("lancement AVEC PANIER = " +
                                        model.getmonpanier.plats
                                            .where((ee) => ee.isactive == true)
                                            .toString() +
                                        " les plats enregistre ==" +
                                        lesplats.toString());
                                    model.sauvegardeCommande(false, lesplats,
                                        lesvariants, lesallergies);
                                    //    model.supprimercommandeprov());
                                    model.supprimercommandeprov(iddelatable);
                                  }
                                });

                                widget.setpartie(5);
                                //   Timer(Duration(milliseconds: 700), () {});
                              },
                              child: Column(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        // color: Colors.blue,
                                        border: Border.all(
                                            color: Colors.black,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                80),
                                        borderRadius:
                                            BorderRadius.circular(85848484),
                                        color: choix == "1"
                                            ? Theme.of(context).primaryColor
                                            : Colors.transparent,
                                      ),
                                      height:
                                          MediaQuery.of(context).size.width / 6,
                                      width:
                                          MediaQuery.of(context).size.width / 6,
                                      child: Center(
                                          child: CachedNetworkImage(
                                        cacheManager: customcachemanager,
                                        fadeInDuration:
                                            Duration(microseconds: 0),
                                        fadeOutDuration:
                                            Duration(microseconds: 0),
                                        imageUrl: payement.image,
                                        fit: BoxFit.contain,
                                        height:
                                            MediaQuery.of(context).size.width /
                                                8,
                                      ))),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.height / 6,
                                    child: Text(
                                      payement.nom,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: payement.nom.length > 16
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  50
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  40),
                                    ),
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
