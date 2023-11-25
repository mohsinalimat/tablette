import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';
import 'package:tablette/model/ModelTable.dart';
import '../model/RestaurantModel.dart';
import '../model/PanierModel.dart';
import '../model/ModelProduits.dart';
import '../model/ModelVariants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/ClientModel.dart';
import '../model/PayementModel.dart';
import 'package:diacritic/diacritic.dart';

class mainsScoped extends Model {
  List listmenus = [];
  get getlistmenus {
    return listmenus;
  }

  List maisondata = [];
  get getmaisondata {
    return maisondata;
  }

  restauration() {
    solde = 0.0;
    listmenus = [];
    monpanier = PanierModel([], [], []);
    userfidelity = "";
    userfidelity = "";
    client = [];
    allergies = [];
    dernierecommande = [];
    table = 0;
    nbrepersonne = 0;
    nomutilisateur = "";
    restaurationipdynamique();
    notifyListeners();
  }
  // modification theme

  int choix = 0;
  get getchoix {
    return choix;
  }

  setchoix(choixnumber) {
    choix = choixnumber;
    notifyListeners();
  }

  // utilisation de data

  List listvariants = [];

  get getlistvariants {
    return listvariants;
  }

  List listplats = [];
  get getlistplats {
    return listplats;
  }

  double solde = 00.00;
  get getsolde {
    return solde;
  }

  addsolde(somme) {
    solde = solde + somme;
    notifyListeners();
  }

  PanierModel monpanier = PanierModel([], [], []);
  annulercommande() {
    monpanier = PanierModel([], [], []);
    solde = 00.00;
    allergies = [];
    notifyListeners();
  }

  get getmonpanier {
    return monpanier;
  }

  ajouterplats(data, indexplatancien) {
    // recuperation index

    print("l'index trouvé pour le plat est " + indexplatancien.toString());
    if (indexplatancien != -1) {
      print("on a trouve un plat");
      monpanier.plats[indexplatancien].quantity =
          (int.parse(monpanier.plats[indexplatancien].quantity) +
                  int.parse(data.quantity.toString()))
              .toString();
      print("le resultat est maintenant " +
          monpanier.plats[indexplatancien].name);
      notifyListeners();
    } else {
      print(" ici l'index est different de -1");
      monpanier.plats.add(data);
      notifyListeners();
    }

    notifyListeners();
  }

  retirerplat(data) {
    print("suppression en cours");
    // suppression du plat
    monpanier.plats[monpanier.plats.indexOf(data)].isactive = false;
    // solde
    solde = solde -
        (double.parse(data.quantity.toString()) *
            double.parse(data.price.toString()));
    monpanier.variants
        .where(
      (element) =>
          element.product_id_index == monpanier.plats.indexOf(data).toString(),
    )
        .forEach((element) {
      solde = solde - double.parse(element.price.toString());
    });
    // suppression des variants
    monpanier.variants.removeWhere(
      (element) =>
          element.product_id_index == monpanier.plats.indexOf(data).toString(),
    );

    notifyListeners();
  }

  Ajoutervariants(data) {
    monpanier.variants.add(data);
    solde = solde + double.parse(data.price.toString());
    notifyListeners();
  }

  SupprimerMonplat(index) {
    monpanier.plats.removeAt(index);
    monpanier.variants
        .removeWhere((es) => es.product_id_index == index.toString());
    monpanier.extras
        .removeWhere((es) => es.product_id_index == index.toString());
    double soldeplat = monpanier.plats.fold(
        0,
        (total, element) =>
            total +
            double.parse(
                (int.parse(element.quantity) * double.parse(element.price))
                    .toString()));
    double soldevariant = monpanier.variants
        .fold(0, (total, element) => total + double.parse(element.price));
    double soldeextras = monpanier.extras
        .fold(0, (total, element) => total + double.parse(element.price));
    solde = soldeplat + soldevariant + soldeextras;

    monpanier.variants.forEach((element) {
      if (int.parse(element.product_id_index) > index) {
        element.product_id_index =
            (int.parse(element.product_id_index) - 1).toString();

        print("element variant superieur" + element.product_id_index);
        monpanier.extras
            .replaceRange(0, monpanier.extras.length, monpanier.extras);
      } else {
        print("element variant inferieur " + element.product_id_index);
      }
    });

    monpanier.extras.forEach((element) {
      if (int.parse(element.product_id_index) > index) {
        element.product_id_index =
            (int.parse(element.product_id_index) - 1).toString();

        print("element superieur" + element.product_id_index);
        monpanier.extras
            .replaceRange(0, monpanier.extras.length, monpanier.extras);
      } else {
        print("element inferieur " + element.product_id_index);
      }
    });
    //  print(monpanier.extras[1].product_id_index);
    notifyListeners();
  }

  ModifierPlat(index, datavariant) {
    monpanier.variants
        .removeWhere((es) => es.product_id_index == index.toString());
    monpanier.extras
        .removeWhere((es) => es.product_id_index == index.toString());

    //    monpanier.extras.add(data);
    monpanier.variants.add(datavariant);
    double soldeplat = monpanier.plats
        .fold(0, (total, element) => total + double.parse(element.price));
    double soldevariant = monpanier.variants
        .fold(0, (total, element) => total + double.parse(element.price));
    double soldeextras = monpanier.extras
        .fold(0, (total, element) => total + double.parse(element.price));
    solde = soldeplat + soldevariant + soldeextras;

    //  print(monpanier.extras[1].product_id_index);
    notifyListeners();
  }

  //String adresseserveur = "192.168.8.7";217.182.171.187
  String adresseserveur = "";
  Future fetchData() async {
    notifyListeners();

    final response = await http.get(Uri.parse('http://' +
        adresseserveur +
        '/' +
        nomresto.toString() +
        '/restaurant_info.php'));

    if (response.statusCode == 200) {
      maisondata = [];
      List dataList = List.from(jsonDecode(response.body));
      maisondata = [
        RestaurantModel(
            dataList[0]["name"],
            dataList[0]["adress"],
            dataList[0]["email"],
            dataList[0]["logo"],
            dataList[0]["phone"],
            dataList[0]["color1"],
            dataList[0]["color2"])
      ];
      print(" j'ai maintenant :" + maisondata[0].nom);
      notifyListeners();
    } else {
      notifyListeners();
      throw Exception('Erreur de chargement des données');
    }
    notifyListeners();
  }

  List mescategories = [];
  get getmescategories {
    return mescategories;
  }

  Future fetchcategories() async {
    final response = await http.get(Uri.parse('http://' +
        adresseserveur.toString() +
        '/' +
        nomresto.toString() +
        '/categories.php'));

    if (response.statusCode == 200) {
      mescategories = [];
      List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(jsonDecode(response.body));
      //  dynamic resultat = response.body;
      dataList.forEach((e) {
        mescategories
            .add({"id": e['id'], "name": e['name'], "image": e["image"]});
      });

      notifyListeners();
      // return response.body;
    } else {
      throw Exception('Erreur de chargement des données');
    }
  }

  int categorieschoisie = 0;
  get getcategorieschoisie {
    return categorieschoisie;
  }

  setcategorieschoisie(id) {
    categorieschoisie = id;
    notifyListeners();
  }

  List Tableauproduits = [];
  get gettableauproduits {
    return Tableauproduits;
  }

  Future fetchProduits() async {
    final response = await http.get(Uri.parse('http://' +
        adresseserveur.toString() +
        '/' +
        nomresto.toString() +
        '/produits.php'));
    List<int> parseNumberList(String value) {
      if (value == "") {
        return []; // Retourne un tableau vide si la valeur est vide
      }

      String cleanValue = value.replaceAll('"', '');
      List<String> numberStrings = cleanValue.split(',');
      List<int> numbersList =
          numberStrings.map((str) => int.tryParse(str) ?? 0).toList();

      return numbersList;
    }

    if (response.statusCode == 200) {
      Tableauproduits = [];
      List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(jsonDecode(response.body));
      //  dynamic resultat = response.body;
      dataList.forEach((e) {
        Tableauproduits.add(ModelProduit(
            e['id'],
            e['name'],
            e['description'],
            e['image'] == null ? "" : e["image"],
            e['price'],
            e['category_id'],
            "1",
            parseNumberList(e['produitsup'] ?? ""),
            true)); // Ajout de la vérification ici
      });

      print("le resultat pour l'affichage des produits est " +
          Tableauproduits.toString());
      notifyListeners();
      // return response.body;
    } else {
      throw Exception('Erreur de chargement des données');
    }
  }

  List messagesList = [];
  get getmessageList {
    return messagesList;
  }

  List tableauvariants = [];
  get gettableauvariant {
    return tableauvariants;
  }

  List variantList = [];
  get getvariantList {
    return variantList;
  }

  Future fetchvariants() async {
    final response = await http.get(Uri.parse('http://' +
        adresseserveur.toString() +
        '/' +
        nomresto.toString() +
        '/variants_produits.php'));

    if (response.statusCode == 200) {
      variantList = [];
      tableauvariants = [];
      List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(jsonDecode(response.body));
      dataList.forEach((e) {
        tableauvariants.add(ModelVariants(
          e["id"],
          e['product_id'],
          e['name'],
          e['price'],
          "9999999999999999999",
          e["image"] == null
              ? "https://th.bing.com/th/id/OIP.fvZrg7evNt1QRoCLqcGw3AHaEL?pid=ImgDet&rs=1"
              : e["image"],
          e["message"] == null ? "" : e["message"],
        ));
        // Ajouter le message à la liste distincte
        if (e["message"] != "" &&
            !variantList.any((item) =>
                item["message"] == e["message"] &&
                item["productid"] == e["product_id"])) {
          variantList.add({
            "message": e["message"],
            "limit": e["nbremax"],
            "productid": e["product_id"],
            "isrequired": e['isrequired']
          });
        }
      });

      notifyListeners();
    } else {
      throw Exception('Erreur de chargement des données');
    }
  }

  String idcommande = '0';
  get getidcommande {
    return idcommande;
  }

  creerCommande(statut, type, payement, nomutilise, nbrepersonnes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var clientid;
    if (client.isEmpty) {
      clientid = null;
      print("il n'y a pas de client");
      print("et ca renvoie " + clientid.toString());
      final response = await http.get(Uri.parse('http://' +
          adresseserveur.toString() +
          '/' +
          prefs.getString("resto").toString() +
          "/creerCommande2.php?status=$statut&type=$type&payement=$payement&client_id=$clientid&name=$nomutilise&table=${table.toString()}&personne=$nbrepersonnes"));
      if (response.statusCode == 200) {
        print(response.body);
        idcommande = response.body.toString();
        notifyListeners();
        return true;
      } else {
        print("ca return false");
        return false;
      }
    } else {
      //  var clientnom = client[0].username;
      clientid = int.parse(client[0].id.toString());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(Uri.parse('http://' +
          adresseserveur.toString() +
          '/' +
          nomresto.toString() +
          '/creerCommande.php?status=$statut&type=$type&payement=$payement&client_id=$clientid&name=$nomutilise&table=${table.toString()}&personne=${nbrepersonne}'));
      if (response.statusCode == 200) {
        print(response.body);
        idcommande = response.body.toString();
        // return true;
        print("le client est " + getclient.toString());
        var idclient = client[0].id;
        var pointsacquis = solde.round();
        final responsehistory = await http.get(Uri.parse('http://' +
            adresseserveur.toString() +
            '/' +
            prefs.getString("resto").toString() +
            '/addfidelityhistory.php?order_id=$idcommande&client_id=$idclient&points=$pointsacquis'));

        // incrementation des points
        final responseuserspoint = await http.get(Uri.parse('http://' +
            adresseserveur.toString() +
            '/' +
            nomresto.toString() +
            '/countpointsfidelite.php?iduser=$idclient&ajoutpoint=$pointsacquis'));
        notifyListeners();
        return true;
      }
    }
    notifyListeners();
  }

  sauvegardeCommande(
      aveccodepromo, dataplats, datavariant, dataallergies) async {
    print(
        "methode sauvegarde avec dans le panier " + monpanier.plats.toString());
    dataplats.forEach((element) async {
      print("enregistrement de " + element.toString());
      double somme = 0.0;
      monpanier.extras.where((elements) {
        if (elements.product_id_index ==
            dataplats.indexOf(element).toString()) {
          somme = somme + double.parse(elements.price);
        }
        return true;
      });
      datavariant.where((elements) {
        if (elements.product_id_index ==
            dataplats.indexOf(element).toString()) {
          somme = somme + double.parse(elements.price);
        }
        return true;
      });
      double calculprix = double.parse(element.price) + somme;

      String order_id = idcommande;
      String product_id = element.id;
      String quantite = element.quantity.toString();
      String prix = aveccodepromo == false
          ? calculprix.toStringAsFixed(2).toString()
          : (calculprix - calculprix * 0.1).toStringAsFixed(2).toString();
      String vat = getchoix == 1 ? "5.5" : "10";
      final List<String> nomsAffiches = [];

      List<Map<String, dynamic>> mesextras = monpanier.extras
          .where((elements) =>
              elements.product_id_index ==
              dataplats.indexOf(element).toString())
          .map((elements) {
            final nom = elements.nom.toString();
            final quantite = monpanier.extras
                .where((elementss) =>
                    elementss.product_id_index ==
                        monpanier.plats.indexOf(element).toString() &&
                    elementss.nom == nom)
                .length
                .toString();

            if (!nomsAffiches.contains(nom)) {
              nomsAffiches.add(nom);
              return {
                'name': removeDiacritics(nom),
                'quantity': quantite.toString(),
                'price': elements.price.toString(),
              };
            } else {
              return null;
            }
          })
          .where((element) => element != null)
          .cast<Map<String, dynamic>>()
          .toList();

      String extras = jsonEncode(mesextras);
      print('comme extras on a : ' + extras);

      List<Map<String, dynamic>> mesvariants = datavariant
          .where((elements) =>
              elements.product_id_index ==
              dataplats.indexOf(element).toString())
          .map((elements) {
            final nom = elements.nom.toString();
            final quantite = datavariant
                .where((elementss) =>
                    elementss.product_id_index ==
                        dataplats.indexOf(element).toString() &&
                    elementss.nom == nom)
                .length
                .toString();

            if (!nomsAffiches.contains(nom) && nom != "rien") {
              nomsAffiches.add(nom);
              return {
                'name': nom,
                'quantity': quantite.toString(),
                'price': elements.price.toString(),
                'message': elements.message.toString()
              };
            } else {
              return null;
            }
          })
          .where((element) => element != null)
          .cast<Map<String, dynamic>>()
          .toList();

      String variant = jsonEncode(mesvariants);
      //   print('comme variant on a : ' + variant);
      List? notes = [];

      dataallergies
          .where((element) => element["produit"] == product_id)
          .forEach((elemen) {
        notes.add(elemen["data"]);
      });

      print("la liste des allergennes enregistres = " + notes.toString());
      //  SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(Uri.parse("http://" +
          adresseserveur.toString() +
          "/" +
          nomresto.toString() +
          "/enregistrerCommande.php?order_id=$order_id&product_id=$product_id&quantity=$quantite&price=$prix&vat=$vat&extras=$extras&variant=$variant&notes=${notes.toString()}"));

      if (response.statusCode == 200) {
        print(response.body);
        print("envoie reussie");
      } else {
        throw Exception('Erreur');
      }
    });
    print("sortie de la methode");
  }

  String nomresto = "";

  Future testlicense(adress, textentree) async {
    print("recherche license de " + textentree.toString());
    final response = await http.get(Uri.parse('http://' +
        adress.toString() +
        '/getlicense.php?clelicense=$textentree'));
    if (response.statusCode == 200) {
      if (response.body.toString() == "true") {
        print("c'est ok");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List separation = adress.toString().split("/");
        nomresto = separation[1].toString();
        prefs.setString("license", textentree.toString());
        prefs.setString("resto", separation[1].toString());
        notifyListeners();
        return true;
      } else {
        print("c'est pas ok");
        return false;
      }
    } else {
      print("echec");
      return false;
    }
  }

  // address ip dynamique
  restaurationipdynamique() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adresseserveur = prefs.getString("dynamicip").toString();
    nomresto = prefs.getString("resto").toString();

    notifyListeners();
  }

  Future testconnexion(server) async {
    print("je teste " + server);

    final response = await http
        .get(Uri.parse('http://' + server.toString() + '/getconnection.php'));
    if (response.statusCode == 200) {
      print("jentre");
      adresseserveur = server.toString();
      List separation = server.toString().split("/");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("dynamicip", separation[0].toString());
      notifyListeners();

      notifyListeners();
      maisondata = [];
      final response1 = await http
          .get(Uri.parse('http://' + server + '/restaurant_info.php'));

      if (response1.statusCode == 200) {
        List dataList = List.from(jsonDecode(response1.body));
        maisondata = [
          RestaurantModel(
              dataList[0]["name"],
              dataList[0]["adress"],
              dataList[0]["email"],
              dataList[0]["logo"],
              dataList[0]["phone"],
              dataList[0]["color1"],
              dataList[0]["color2"])
        ];
        notifyListeners();
      } else {
        notifyListeners();
        return false;
      }
      final response2 = await http.get(
          Uri.parse('http://' + server.toString() + '/' + '/getlanguages.php'));
      if (response2.statusCode == 200) {
        notifyListeners();
        List receuil = [];
        List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(jsonDecode(response2.body));
        dataList.forEach((e) {
          receuil.add(e["code"].toString());
        });
        languagesdata = receuil;
        notifyListeners();
        // return response.body;
      } else {
        notifyListeners();
        return false;
      }
      notifyListeners();
      datainfos = [];
      final response3 =
          await http.get(Uri.parse('http://' + server + '/infoskios.php'));
      if (response3.statusCode == 200) {
        List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(jsonDecode(response3.body));
        dataList.forEach((e) {
          datainfos.add({
            "id": e['id'],
            "theme": e['theme'],
            "license": e["license"],
            "state": e["state"],
            "img_holder": e["img_holder"],
            "isactive": e["isactive"],
            "vendorid": e["vendorid"],
            "deviceid": e["deviceid"],
            "mode_order": e["mode_order"],
          });
          notifyListeners();
        });

        notifyListeners();
        // return response.body;
      } else {
        notifyListeners();
        return false;
      }
      tableauvideos = [];
      final response4 =
          await http.get(Uri.parse('http://' + server + '/getvideo.php'));
      if (response4.statusCode == 200) {
        List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(jsonDecode(response4.body));
        dataList.forEach((e) {
          e["active"].toString() == "1" ? tableauvideos.add(e['url']) : null;
        });

        notifyListeners();
        // return response.body;
      } else {
        notifyListeners();
        return false;
      }
      return true;
    } else {
      print("error d'enregistrement");
      notifyListeners();
      return false;
    }
  }

  String userfidelity = "";
  get getuserfidelity {
    return userfidelity;
  }

  effaceruser() {
    userfidelity = "";
    notifyListeners();
  }

  List datainfos = [];

  get getdatainfos {
    return datainfos;
  }

  Future fetchinfos() async {
    final response = await http.get(Uri.parse('http://' +
        adresseserveur +
        '/' +
        nomresto.toString() +
        '/infoskios.php'));
    if (response.statusCode == 200) {
      print("recuperarion des informations");
      datainfos = [];
      List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(jsonDecode(response.body));

      dataList.forEach((e) {
        datainfos.add({
          "id": e['id'],
          "theme": e['theme'],
          "license": e["license"],
          "state": e["state"],
          "img_holder": e["img_holder"],
          "isactive": e["isactive"],
          "vendorid": e["vendorid"],
          "deviceid": e["deviceid"],
          "mode_order": e["mode_order"],
          "img_mode_order": json.decode(e["img_mode_order"]),
          "background": e["background"]
        });
      });

      notifyListeners();

      return response.body;
    } else {
      notifyListeners();
      throw Exception('Erreur de chargement des données');
    }
  }

  List imagespromo = [];
  get getimagespromo {
    return imagespromo;
  }

  Future fetchpromoimage() async {
    final response = await http.get(Uri.parse('http://' +
        adresseserveur +
        '/' +
        nomresto.toString() +
        '/imagespromo.php'));
    if (response.statusCode == 200) {
      imagespromo = [];
      List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(jsonDecode(response.body));
      //  dynamic resultat = response.body;
      dataList.forEach((e) {
        if (e["state"] == "active") {
          imagespromo.add({
            "id": e['id'],
            "name": e['name'],
            "type": e["type"],
            "link": e["link"]
          });
          notifyListeners();
        }
      });

      notifyListeners();
      // return response.body;
    } else {
      notifyListeners();
      throw Exception('Erreur de chargement des données');
    }
  }

  List tableauvideos = [];
  get gettableauvideos {
    return tableauvideos;
  }

  bool modifvideo = false;
  get getmodifvideo {
    return modifvideo;
  }

  Future fetchvideos() async {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse('http://' +
        adresseserveur +
        '/' +
        nomresto.toString() +
        '/getvideo.php'));
    if (response.statusCode == 200) {
      tableauvideos = [];
      List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(jsonDecode(response.body));
      dataList.forEach((e) {
        e["active"].toString() == "1" ? tableauvideos.add(e['url']) : null;
      });
      notifyListeners();
      print(" les videos recupereres sont " + tableauvideos.toString());
      return response.body;
    } else {
      notifyListeners();
      throw Exception('Erreur de chargement des données');
    }
  }

  List languagesdata = [];
  get getlanguagesdata {
    return languagesdata;
  }

  Future fetchlanguages() async {
    final response = await http.get(Uri.parse('http://' +
        adresseserveur +
        '/' +
        nomresto.toString() +
        '/getlanguages.php'));
    if (response.statusCode == 200) {
      languagesdata = [];
      List receuil = [];
      List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(jsonDecode(response.body));
      dataList.forEach((e) {
        if (e["state"].toString() == "1") {
          receuil.add(e["code"].toString());
          print("recuperation element " + e["code"].toString());
        }
      });
      languagesdata = receuil;
      print("finalement j'ai maintenant " + languagesdata.toString());
      notifyListeners();
      return response.body;
    } else {
      notifyListeners();
      throw Exception('Erreur de chargement des données');
    }
  }

  List<ClientModel> client = [];
  get getclient {
    return client;
  }

  Modifierquantity(indexplat, type, prix) {
    print("modification avec " +
        indexplat.toString() +
        " et type = " +
        type.toString() +
        " et prix =" +
        prix.toString());
    if (type == 1) {
      print("ici avec index " + indexplat.toString());
      monpanier.plats[indexplat].quantity =
          (int.parse(monpanier.plats[indexplat].quantity) + 1).toString();
      solde = solde + double.parse(prix);
      notifyListeners();
    } else {
      print("plutot ici avec index " + indexplat.toString());
      if (int.parse(monpanier.plats[indexplat].quantity) > 1) {
        monpanier.plats[indexplat].quantity =
            (int.parse(monpanier.plats[indexplat].quantity) - 1).toString();
        solde = solde - double.parse(prix);
        notifyListeners();
      }
    }
  }

  List lespayements = [];
  get getlespayements {
    return lespayements;
  }

  Future fetchpayement() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse('http://' +
        adresseserveur +
        '/' +
        prefs.getString("resto").toString() +
        '/getpayement.php'));
    if (response.statusCode == 200) {
      lespayements = [];
      List receuil = [];
      List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(jsonDecode(response.body));
      dataList.forEach((e) {
        if (e["isactive"].toString() == "1") {
          receuil.add(PayementModel(e["nom"], e["image"], e["indicatif"]));
        }
      });
      lespayements = receuil;
      print("finalement j'ai maintenant " + lespayements.toString());
      notifyListeners();
      return response.body;
    } else {
      notifyListeners();
      throw Exception('Erreur de chargement des données');
    }
  }

  String languesselectionne = "fr";
  get getlanguesselectionne {
    return languesselectionne;
  }

  setlangueselectionne(lg) {
    print("la langue changee est " + lg.toString());
    languesselectionne = lg;
    notifyListeners();
  }

  int table = 0;
  get gettable {
    return table;
  }

  settable(nber) {
    table = nber;
    notifyListeners();
  }

  //creation et connexion au compte
  Future<void> loginUser(String username, String password) async {
    final String apiUrl =
        'http://' + adresseserveur + '/ ' + nomresto.toString() + '/login.php';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      print('Response: ${response.body}');
    } else {
      print('Error: ${response.reasonPhrase}');
    }
  }

  //derniere commande
  List dernierecommande = [];
  get getderniercommande {
    return dernierecommande;
  }

  Future fetchdernierecommande() async {
    try {
      final response = await http.get(Uri.parse('http://' +
          adresseserveur +
          '/' +
          nomresto.toString() +
          '/dernierecommande.php?table=$table'));

      if (response.statusCode == 200) {
        dernierecommande = [];

        List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));

        dernierecommande = dataList;
        print("finalement j'ai maintenant " + dernierecommande.toString());
        notifyListeners();
      } else {
        // Gestion de l'erreur HTTP
        notifyListeners();
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      // Gestion de toutes les autres erreurs possibles
      notifyListeners();
      throw Exception(
          'Erreur lors de la récupération de la derniere commande :');
    }
  }

  Future testtablee(textentree) async {
    print("recherche table code de " + textentree.toString());
    final response = await http.get(Uri.parse('http://' +
        adresseserveur +
        '/' +
        nomresto.toString() +
        '/getcodetable.php?cletable=$textentree'));
    if (response.statusCode == 200) {
      if (response.body.toString() == "true") {
        print("c'est ok");
        notifyListeners();
        return true;
      } else {
        print("c'est pas ok");
        return false;
      }
    } else {
      print("echec");
      return false;
    }
  }

  Future fetchlogin(code) async {
    final response = await http.get(Uri.parse('http://' +
        adresseserveur.toString() +
        '/' +
        nomresto +
        '/users.php?phone=$code'));
    if (response.statusCode == 200) {
      client = [];
      if (response.body != "null_element") {
        Map<String, dynamic> data = jsonDecode(response.body);
        client.add(ClientModel(
          data["id"].toString(),
          data["username"].toString(),
          data["email"].toString(),
          data["points"].toString(),
          data["phone"].toString(),
          data["address"].toString(),
          data["state"].toString(),
        ));

        userfidelity = response.body;
        notifyListeners();
      }
    } else {
      notifyListeners();
    }
  }

  Future inscription(numero, passwordnumero, email) async {
    print('lancement de linscription');

    final response = await http.get(Uri.parse('http://' +
        adresseserveur.toString() +
        '/' +
        nomresto +
        '/inscription.php?numero=$numero&passwordnumero=$passwordnumero&email=$email'));
    if (response.statusCode == 200) {
      client = [];
      if (response.body == "Inscription réussie") {
        fetchlogin(numero);
        userfidelity = response.body;
        notifyListeners();
        return true;
      }
    } else {
      notifyListeners();
      return false;
    }
  }

  // ajout des allergies

  List allergies = [];
  get getallergies {
    return allergies;
  }

  ajouterallergies(idproduit, data) {
    allergies.add({"produit": idproduit, "data": data});
    notifyListeners();
    print("ajout effectue");
    print(" le tableau contiens maintenant " + allergies.toString());
    notifyListeners();
  }

  List allergiesdb = [];
  get getallergiesdb {
    return allergiesdb;
  }

  Future fetchallergies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse('http://' +
        adresseserveur +
        '/' +
        prefs.getString("resto").toString() +
        '/getallergies.php'));

    if (response.statusCode == 200) {
      // Convertir la réponse JSON en une liste de chaînes
      List<dynamic> allergyList = json.decode(response.body);
      print('les allergies recuperes sont : ' + allergyList.toString());

      if (allergyList.isNotEmpty) {
        // Mettre à jour la liste d'allergies
        allergiesdb = allergyList;
        print("J'ai maintenant les allergies : " + allergiesdb.toString());
        notifyListeners();
      } else {
        // La liste d'allergies est vide
        notifyListeners();
        throw Exception('Aucune allergie n\'a été trouvée');
      }
    } else {
      // Erreur de réponse HTTP
      notifyListeners();
      throw Exception('Erreur de chargement des données');
    }
    notifyListeners();
  }

  // recuperation table
  List mestables = [];
  get getmestables {
    return mestables;
  }

  Future fetchTable() async {
    final response = await http.get(Uri.parse(
        'http://' + adresseserveur + '/' + nomresto + '/gettable.php'));
    if (response.statusCode == 200) {
      mestables = [];
      // List receuil = [];
      List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(jsonDecode(response.body));
      dataList.forEach((e) {
        mestables.add(ModelTable(
            int.parse(e['id'].toString()),
            int.parse(e['numero'].toString()),
            int.parse(e["nbre_cv"].toString()),
            int.parse(e["etat"].toString())));
      });
      // lespayements = receuil;
      print("finalement j'ai maintenant " + mestables.toString());
      notifyListeners();
    } else {
      notifyListeners();
      throw Exception('Erreur de chargement des données');
    }
    notifyListeners();
  }

// changement de table
  enregistrercommandeprov(aveccodepromo) {
    monpanier.plats.forEach((element) async {
      double somme = 0.0;
      monpanier.extras.where((elements) {
        if (elements.product_id_index ==
            monpanier.plats.indexOf(element).toString()) {
          somme = somme + double.parse(elements.price);
        }
        notifyListeners();
        return true;
      });
      monpanier.variants.where((elements) {
        if (elements.product_id_index ==
            monpanier.plats.indexOf(element).toString()) {
          somme = somme + double.parse(elements.price);
        }
        notifyListeners();
        return true;
      });
      double calculprix = double.parse(element.price) + somme;

      String table_id = table.toString();
      String product_id = element.id;
      String desc = element.description.toString();
      String quantite = element.quantity.toString();
      String prix = aveccodepromo == false
          ? calculprix.toStringAsFixed(2).toString()
          : (calculprix - calculprix * 0.1).toStringAsFixed(2).toString();
      String vat = getchoix == 1 ? "5.5" : "10";
      final List<String> nomsAffiches = [];

      List<Map<String, dynamic>> mesextras = monpanier.extras
          .where((elements) =>
              elements.product_id_index ==
              monpanier.plats.indexOf(element).toString())
          .map((elements) {
            final nom = elements.nom.toString();
            final quantite = monpanier.extras
                .where((elementss) =>
                    elementss.product_id_index ==
                        monpanier.plats.indexOf(element).toString() &&
                    elementss.nom == nom)
                .length
                .toString();

            if (!nomsAffiches.contains(nom)) {
              nomsAffiches.add(nom);
              return {
                'name': removeDiacritics(nom),
                'quantity': quantite.toString(),
                'price': elements.price.toString(),
              };
            } else {
              notifyListeners();
              return null;
            }
          })
          .where((element) => element != null)
          .cast<Map<String, dynamic>>()
          .toList();

      String extras = jsonEncode(mesextras);
      print('comme extras on a : ' + extras);

      List<Map<String, dynamic>> mesvariants = monpanier.variants
          .where((elements) =>
              elements.product_id_index ==
              monpanier.plats.indexOf(element).toString())
          .map((elements) {
            final nom = elements.nom.toString();
            final quantite = monpanier.variants
                .where((elementss) =>
                    elementss.product_id_index ==
                        monpanier.plats.indexOf(element).toString() &&
                    elementss.nom == nom)
                .length
                .toString();

            if (!nomsAffiches.contains(nom) && nom != "rien") {
              nomsAffiches.add(nom);
              return {
                'name': removeDiacritics(nom.toString()),
                'quantity': quantite.toString(),
                'price': elements.price.toString(),
                'message': elements.message.toString()
              };
            } else {
              return null;
            }
          })
          .where((element) => element != null)
          .cast<Map<String, dynamic>>()
          .toList();

      String variant = jsonEncode(mesvariants);
      print('comme variant on a : ' + variant);
      List? notes = [];

      allergies
          .where((element) => element["produit"] == product_id)
          .forEach((elemen) {
        notes.add(elemen["data"]);
      });
      notifyListeners();

      print("la liste des allergennes enregistres = " + notes.toString());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(Uri.parse("http://" +
          adresseserveur.toString() +
          "/" +
          prefs.getString("resto").toString() +
          "/enregistrerCommandeprov.php?table_id=$table_id&product_id=$product_id&description=$desc&quantity=$quantite&price=$prix&vat=$vat&variant=$variant&notes=${notes.toString()}"));

      if (response.statusCode == 200) {
        print(response.body);
        print("envoie reussie");
      } else {
        throw Exception('Erreur');
      }
      notifyListeners();
    });
    notifyListeners();
  }

  supprimercommandeprov(iddelatable) async {
    print("on veut supprimer la table " + iddelatable.toString());
    String tableasupprimer = iddelatable.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse("http://" +
        adresseserveur.toString() +
        "/" +
        prefs.getString("resto").toString() +
        "/supprimerCommandeprov.php?table_id=$tableasupprimer"));

    if (response.statusCode == 200) {
      print(response.body);
      print("suppression dans la table provisoire reussie");
      notifyListeners();
    } else {
      throw Exception('Erreur');
    }
    notifyListeners();
  }

  recuperationcommandeprov() async {
    final response = await http.get(Uri.parse('http://' +
        adresseserveur +
        '/' +
        nomresto +
        '/getcommandeprov.php?table_id=$table'));
    if (response.statusCode == 200) {
      print("recuperarion des commandes provisoires");
      datainfos = [];
      List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(jsonDecode(response.body));
      List data = [];
      dataList.forEach((e) {
        data.add({
          "productid": e["produitid"].toString(),
          "title": e["title"].toString(),
          "quantity": e["quantity"].toString(),
          "variants": e["variants"],
          "notes": e['notes'].toString(),
          "price": e['price'].toString(),
          "description": e["description"],
        });
        notifyListeners();
      });
      notifyListeners();
      monpanier = PanierModel([], [], []);
      solde = 0;
      //maintenant ajouter dans le panier
      if (data.length > 0) {
        solde = 0;
        data.forEach((element) {
          //  addsolde(double.parse(element["quantity"].toString())*)

          double sommevariant = 0;
          monpanier.plats.add(ModelProduit(
              element["productid"],
              element["title"],
              element["description"],
              "image",
              element["price"],
              "category_id",
              element["quantity"],
              [],
              true));
          if (element["variants"] != null) {
            List<dynamic> variantsList = jsonDecode(element["variants"]);
            if (variantsList is List) {
              variantsList.forEach((vars) {
                sommevariant =
                    sommevariant + double.parse(vars['price'].toString());
                monpanier.variants.add(ModelVariants(
                    "00",
                    element["productid"],
                    vars['name'],
                    vars['price'],
                    monpanier.plats.length - 1 < 0
                        ? "0"
                        : (monpanier.plats.length - 1).toString(),
                    "image",
                    vars['message']));
              });
              print("les variants récupérés sont : " +
                  monpanier.variants.toString());
              notifyListeners();
            }
          }

          double sommeproduittotal =
              double.parse(element["quantity"].toString()) *
                  (double.parse(element["price"].toString()) + sommevariant);
          addsolde(sommeproduittotal);
          notifyListeners();
        });
        notifyListeners();
      }
      notifyListeners();

      return response.body;
    } else {
      monpanier = PanierModel([], [], []);
      notifyListeners();
      throw Exception('Erreur de chargement des données');
    }
  }

  String nomutilisateur = "";
  get getnomutilisateur {
    return nomutilisateur;
  }

  setnomutilisateur(nameut) {
    nomutilisateur = nameut;
    notifyListeners();
  }

  int nbrepersonne = 0;
  get getnbrepersonne {
    return nbrepersonne;
  }

  setnombrepersonne(nbre) {
    nbrepersonne = nbre;
    notifyListeners();
  }
}
