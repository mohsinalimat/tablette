import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tablette/scoped/Mains.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class FelicitationPage extends StatefulWidget {
  Function setpartie;
  mainsScoped model;
  FelicitationPage(this.setpartie, this.model);
  @override
  State<FelicitationPage> createState() => _FelicitationPageState();
}

class _FelicitationPageState extends State<FelicitationPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.model.restauration();
  }

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
                  opacity: 0.2,
                  fit: BoxFit.cover)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 6,
                width: MediaQuery.of(context).size.width / 4,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(
                            model.getmaisondata[0].logo.toString()),
                        fit: BoxFit.contain)),
              ),
              Text(
                "merci pour votre commande".tr.toUpperCase() + " !",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width / 20),
              ),
              Text(
                "votre commande est en prepation en cuisine.merci pour votre confiance"
                    .tr,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width / 50),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 3.5,
                width: MediaQuery.of(context).size.width * 2 / 3,
                //   color: Colors.green,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      //   color: Colors.yellow,
                      width: MediaQuery.of(context).size.width * 2 / 9,
                      height: MediaQuery.of(context).size.height / 4.2,
                      child: Center(
                        child: PrettyQr(
                          typeNumber: null,
                          size: MediaQuery.of(context).size.height / 5,
                          data: "lien",
                          errorCorrectLevel: QrErrorCorrectLevel.M,
                          roundEdges: true,
                        ),
                      ),
                    ),
                    Container(
                      //  color: Colors.yellow,
                      width: MediaQuery.of(context).size.width * 4 / 9,
                      height: MediaQuery.of(context).size.height / 4.2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.height / 100,
                                right: MediaQuery.of(context).size.height / 50),
                            margin: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width / 50),
                            width: MediaQuery.of(context).size.width * 4 / 9,
                            height: MediaQuery.of(context).size.height / 12,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width:
                                      MediaQuery.of(context).size.height / 200,
                                  color: Colors.black),
                              color: Theme.of(context).secondaryHeaderColor,
                              borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.height / 70),
                            ),
                            child: Center(
                              child: Text(
                                "telechargez votre recu en scannant le qrcode"
                                    .tr,
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 65,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.height / 100,
                                right: MediaQuery.of(context).size.height / 50),
                            margin: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width / 50),
                            width: MediaQuery.of(context).size.width * 4 / 9,
                            height: MediaQuery.of(context).size.height / 12,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width:
                                      MediaQuery.of(context).size.height / 200,
                                  color: Colors.black),
                              color: Theme.of(context).secondaryHeaderColor,
                              borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.height / 70),
                            ),
                            child: Center(
                              child: Text(
                                "demandez un recu en papier".tr,
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 65,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
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
