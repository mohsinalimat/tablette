import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tablette/scoped/Mains.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// ignore: must_be_immutable
class CategoriesPages extends StatefulWidget {
  Function setparties;
  CategoriesPages(this.setparties);
  @override
  State<CategoriesPages> createState() => _CategoriesPagesState();
}

class _CategoriesPagesState extends State<CategoriesPages> {
  final ScrollController _scrollController = ScrollController();
  static final customcachemanager = CacheManager(Config(
      "tablettecachecategorie",
      stalePeriod: Duration(days: 7),
      maxNrOfCacheObjects: 30));
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<mainsScoped>(
      builder: (context, child, model) {
        return Container(
          height: MediaQuery.of(context).size.height * 9.2 / 10,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: CachedNetworkImageProvider(
                      model.getdatainfos[0]["background"].toString()),
                  opacity: 0.3,
                  fit: BoxFit.cover)),
          //   color: Colors.blue,
          child: Column(
            children: [
              Container(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height / 25),
                height: MediaQuery.of(context).size.height * 9.2 / 35,
                width: MediaQuery.of(context).size.width / 5,
                // color: Colors.blue,
                child: CachedNetworkImage(
                  cacheManager: customcachemanager,
                  fadeInDuration: Duration(milliseconds: 0),
                  fadeOutDuration: Duration(milliseconds: 0),
                  imageUrl: model.getmaisondata[0].logo.toString(),
                  width: MediaQuery.of(context).size.width / 5,
                  height: MediaQuery.of(context).size.height * 9.2 / 35,
                  fit: BoxFit.contain,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 9.2 / 10 -
                    MediaQuery.of(context).size.height * 9.2 / 35,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _scrollController.animateTo(
                          _scrollController.offset -
                              MediaQuery.of(context).size.height /
                                  1.5, // Défilement vers le bas
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width / 9,
                        height: MediaQuery.of(context).size.height,
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Theme.of(context).primaryColor,
                          size: MediaQuery.of(context).size.width / 8,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width / 100),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing:
                              MediaQuery.of(context).size.width / 30,
                          mainAxisSpacing:
                              MediaQuery.of(context).size.width / 30,
                          childAspectRatio:
                              0.92, // Permet d'ajuster la hauteur des éléments
                        ),
                        itemCount: model.getmescategories.length,
                        itemBuilder: (BuildContext context, int index) {
                          var cat = model.getmescategories[index];
                          return GestureDetector(
                            onTap: () {
                              model.fetchallergies();
                              model.fetchdernierecommande();
                              model.fetchProduits();
                              model.fetchpayement();
                              model.fetchTable();
                              model.setcategorieschoisie(int.parse(cat["id"]));

                              widget.setparties(3);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius:
                                            MediaQuery.of(context).size.width /
                                                50,
                                        color: Colors.grey)
                                  ]),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: CachedNetworkImageProvider(
                                          cat["image"],
                                          cacheManager: customcachemanager),
                                    )),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width /
                                          4.5,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              18,
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.9),
                                      child: Center(
                                        child: Text(
                                          cat["name"].toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  50,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _scrollController.animateTo(
                          _scrollController.offset +
                              MediaQuery.of(context).size.height /
                                  1.5, // Défilement vers le bas
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width / 9,
                        height: MediaQuery.of(context).size.height,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).primaryColor,
                          size: MediaQuery.of(context).size.width / 8,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
