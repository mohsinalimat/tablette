// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/material.dart';
import '../scoped/Mains.dart';
import 'Home.dart';

class LoadingPage extends StatefulWidget {
  mainsScoped model;
  LoadingPage(
    this.model,
  );

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(microseconds: 3), () async {
      await widget.model.restaurationipdynamique();
      setState(() {
        essai = !essai;
      });

      widget.model.fetchData();
      widget.model.fetchlanguages();
      widget.model.fetchinfos();
      widget.model.fetchvideos();
      widget.model.fetchpromoimage();
    });

    Timer(Duration(seconds: 4), () {
      widget.model.fetchData();
      widget.model.fetchlanguages();
      widget.model.fetchinfos();
      widget.model.fetchvideos();
      widget.model.fetchpromoimage();
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return HomePage(widget.model);
        },
      ));
    });
  }

  bool essai = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
              image: AssetImage("assets/images/tablette.jpg"),
              fit: BoxFit.scaleDown)),
    );
  }
}
