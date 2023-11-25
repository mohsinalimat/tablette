import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tablette/scoped/Mains.dart';

class Historiques extends StatelessWidget {
  Function retour;
  Historiques(this.retour);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<mainsScoped>(
      builder: (context, child, model) {
        return Container(
          height: MediaQuery.of(context).size.height * 1.85 / 3,
          width: MediaQuery.of(context).size.width / 2,
          color: Theme.of(context).primaryColor.withOpacity(0.8),
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height / 80),
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 1.85 / 3,
                // width: MediaQuery.of(context).size.width / 4,
                //  color: Colors.green,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height / 45),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "historique des commandes".tr.toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height / 50,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 1.65 / 3,
                      //  width: MediaQuery.of(context).size.width / 4,
                      // color: Colors.blue,
                      child: ListView(
                        children: model.getderniercommande
                            .map<Widget>((e) => Container(
                                  margin: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(context).size.height /
                                              40),
                                  //  height: MediaQuery.of(context).size.height / 50,
                                  //   color: Colors.yellow,
                                  //    width: MediaQuery.of(context).size.width / 4,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                15,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              e["quantity"],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    50,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                4,
                                        //     color: Colors.red,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              e["title"],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    50,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                12,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              e["price"].toString() + " €",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    50,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                  bottom: MediaQuery.of(context).size.height / 14,
                  child: GestureDetector(
                    onTap: () {
                      retour();
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 4.3),
                      child: Icon(
                        Icons.arrow_back,
                        size: MediaQuery.of(context).size.height / 15,
                        color: Colors.white,
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
