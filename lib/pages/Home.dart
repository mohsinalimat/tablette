import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../pages/PageTemplate.dart';
import '../scoped/Mains.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class HomePage extends StatefulWidget {
  mainsScoped model;
  HomePage(this.model);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  Stream<DateTime>? _dateTimeStream;
  DateTime? _currentTime;
  Future<void>? _initializeVideoPlayerFuture;
  @override
  void initState() {
    super.initState();
    widget.model.fetchallergies();
    widget.model.restauration();
    widget.model.fetchvideos();
    widget.model.fetchData();
    widget.model.fetchlanguages();
    widget.model.fetchinfos();
    widget.model.fetchvariants();
    widget.model.fetchpayement();
    widget.model.fetchcategories();
    widget.model.fetchProduits();
    widget.model.fetchTable();

    setState(() {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

      videoUrls = widget.model.gettableauvideos;
    });

    _currentTime = DateTime.now();
    _dateTimeStream = Stream<DateTime>.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
    setState(() {
      videoUrls = widget.model.gettableauvideos;
      Get.updateLocale(Locale('fr', "FR"));
      languechoisie = "fr";
    });
    widget.model.setlangueselectionne('fr');

    if (videoUrls.isNotEmpty) {
      _initializeVideoPlayer(videoUrls);
    } else {
      // Gérer le cas où la liste `videoUrls` est vide
      // Par exemple, vous pouvez afficher un message ou utiliser une vidéo de remplacement
    }

    Timer(Duration(seconds: 0), () async {
      print("pour les vidéos on a " + widget.model.gettableauvideos.toString());
      setState(() {
        videoUrls = widget.model.gettableauvideos;
        Get.updateLocale(Locale('fr', "FR"));
        languechoisie = "fr";
      });

      widget.model.setlangueselectionne('fr');
      if (videoUrls.isNotEmpty) {
        _initializeVideoPlayer(videoUrls);
      }
      widget.model.fetchinfos();
      widget.model.fetchvideos();
      setState(() {
        monlogo = widget.model.getmaisondata[0].logo.toString();
        langue = widget.model.getlanguagesdata;
        backgroundimage = widget.model.getdatainfos[0]["img_holder"].toString();
      });
    });
  }

  void _initializeVideoPlayer(List<dynamic> videoUrls) {
    Random random = Random();
    int randomNumber = random.nextInt(videoUrls.length);
    String selectedVideoUrl = videoUrls[randomNumber];

    _controller?.dispose(); // Libère le contrôleur de la vidéo précédente
    setState(() {
      _controller = VideoPlayerController.network(selectedVideoUrl)
        ..setLooping(false) // Désactiver la lecture en boucle
        ..setVolume(0.0);
    });

    _initializeVideoPlayerFuture = _controller?.initialize().then((_) {
      if (_controller != null && _initializeVideoPlayerFuture != null) {
        _initializeVideoPlayerFuture!.then((_) {
          setState(() {
            _controller?.play();
          });
        });
      }
    });

    // Ajouter un écouteur pour détecter la fin de la vidéo
    _controller?.addListener(() {
      if (_controller != null &&
          _controller!.value.position >= _controller!.value.duration) {
        // La vidéo actuelle est terminée, passez à la vidéo suivante
        _playNextVideo(videoUrls);
      }
    });
  }

  void _playNextVideo(List<dynamic> videoUrls) {
    print('Vidéo suivante');
    Random random = Random();
    int randomNumber = random.nextInt(videoUrls.length);
    String selectedVideoUrl = videoUrls[randomNumber];
    _controller?.dispose(); // Libère le contrôleur de la vidéo précédente
    setState(() {
      _controller = VideoPlayerController.network(selectedVideoUrl)
        ..setLooping(false)
        ..setVolume(0.0);
    });

    _initializeVideoPlayerFuture = _controller?.initialize().then((_) {
      if (_controller != null && _initializeVideoPlayerFuture != null) {
        _initializeVideoPlayerFuture!.then((_) {
          setState(() {
            _controller?.play();
          });
        });
      }
    });

    // Ajouter un écouteur pour détecter la fin de la vidéo
    _controller?.addListener(() {
      if (_controller != null &&
          _controller!.value.position >= _controller!.value.duration) {
        // La vidéo actuelle est terminée, passez à la vidéo suivante
        _playNextVideo(videoUrls);
      }
    });
  }

// impression
  String backgroundimage = "";
  String onvois = "";
  String monlogo = "";
  List langue = [];
  String languechoisie = '';
  List<Map<String, dynamic>> listdevicesS = [];
  @override
  void dispose() {
    super.dispose();
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.dispose();
    }
  }

  List transformList(List originalList) {
    Set uniqueElements = {};
    print("nombre d'element " + originalList.length.toString());
    originalList.forEach((element) {
      uniqueElements.add(element);
      if (uniqueElements.length >= 5) {
        return; // Sortir de la boucle si la limite de 5 éléments est atteinte
      }
    });
    return uniqueElements.toList();
  }

  List<dynamic> videoUrls = [];
  static final customcachemanager = CacheManager(Config("tablettecachehome",
      stalePeriod: Duration(days: 7), maxNrOfCacheObjects: 10));
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: null,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
    return ScopedModelDescendant<mainsScoped>(
      builder: (context, child, model) {
        return Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                image: backgroundimage == ""
                    ? null
                    : DecorationImage(
                        opacity: 0.4,
                        image: CachedNetworkImageProvider(backgroundimage,
                            cacheManager: customcachemanager),
                        fit: BoxFit.cover)),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 30),
                  height: MediaQuery.of(context).size.height * 1 / 3,
                  width: MediaQuery.of(context).size.width * 1 / 3,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: CachedNetworkImageProvider(
                              model.getmaisondata[0].logo.toString()))),
                  //  color: Colors.red,
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height / 4,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 5,
                      //  color: Colors.green,
                      child: Center(
                        child: Row(
                          //  scrollDirection: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: model.getlanguagesdata
                              .take(5)
                              .map<Widget>(
                                (edd) => GestureDetector(
                                  onTap: languechoisie == edd
                                      ? null
                                      : () {
                                          print(e.toString());
                                          model.setlangueselectionne(
                                              edd.toString());
                                          setState(() {
                                            languechoisie = edd;
                                          });
                                          Get.updateLocale(
                                              Locale(edd, edd.toUpperCase()));
                                        },
                                  child: Center(
                                    child: Container(
                                      //  color: Colors.yellow,
                                      height:
                                          MediaQuery.of(context).size.width / 5,
                                      width: MediaQuery.of(context).size.width /
                                          10,
                                      margin: EdgeInsets.all(languechoisie !=
                                              edd
                                          ? MediaQuery.of(context).size.width /
                                              25
                                          : 0),
                                      child: CountryFlag.fromCountryCode(
                                        edd,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                10,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      )),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height / 35,
                  child: GestureDetector(
                    onTap: () {
                      model.fetchinfos();
                      if (_controller != null &&
                          _controller!.value.isInitialized) {
                        _controller!.dispose();
                      }
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) {
                          return PageTemplate();
                        },
                      ));
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 1 / 10,
                      width: MediaQuery.of(context).size.width * 1 / 2.5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.height / 10),
                          border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: MediaQuery.of(context).size.height / 100)),
                      child: Center(
                        child: Text(
                          "touchez pour commander".tr.toUpperCase(),
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.height / 30),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
