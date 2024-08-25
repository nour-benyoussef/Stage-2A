import 'dart:convert';

import 'package:flutter/material.dart';
import 'Login.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class Product {
  final String Code;
  final String nom;
  final String Description;
  final double price; // Prix du produit
  int quantity;
  final int stock;  // Stock disponible

  Product(this.Code, this.nom, this.Description, this.price, this.quantity, this.stock);
}


class HomePage extends StatefulWidget {
  final String token;

  const HomePage({required this.token, Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late String email_caissier;
  String _input = ''; // Pour capturer l'entrée utilisateur
  final List<Product> _productList = []; // Liste des produits

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    email_caissier = jwtDecodedToken['email'];
    print(email_caissier);
  }


  void _updateInput(String digit) {
    setState(() {
      _input += digit;
    });
  }

  void _clearInput() {
    setState(() {
      if (_input.isNotEmpty) {
        _input = _input.substring(0, _input.length - 1);
      }
    });
  }

  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 30, // Taille du texte du titre
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 27, // Taille du texte du message
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
              },
              child: Text(
                "OK",
                style: TextStyle(
                  fontSize: 27, // Taille du texte du bouton
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _validateInput() async {
    if (_input.isNotEmpty) {
      var reqBody = {"code": _input};

      var response = await http.post(Uri.parse(AfficheArticle),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody));

      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status']) {
        setState(() {
          var article = jsonResponse['article'];

          double prix = (article['prix'] is int)
              ? (article['prix'] as int).toDouble()
              : article['prix'];

          String nom = article['nom'];
          String description = article['description'];
          int stock = article['stock'];  // Récupérer le stock disponible

          bool productExists = false;

          for (var product in _productList) {
            if (product.Code == _input) {
              if (product.quantity < stock) {  // Vérifier le stock
                product.quantity++;
              } else {
                _showAlertDialog(context, "Stock insuffisant", "Le stock disponible est de $stock unités.");
              }
              productExists = true;
              break;
            }
          }

          if (!productExists) {
            _productList.add(Product(_input, nom, description, prix, 1, stock));
          }

          _input = '';
        });
      } else {
        _showAlertDialog(context, "Erreur", "Article non trouvé.");
      }
    }
  }



  void _increaseQuantity(int index) {
    setState(() {
      var product = _productList[index];

      if (product.quantity < product.stock) {  // Vérifier le stock disponible
        product.quantity++;
      } else {
        _showAlertDialog(context, "Stock insuffisant", "Le stock disponible pour ce produit est limité à ${product.stock} unités.");
      }
    });
  }


  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 300, // Largeur du dialogue
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Êtes-vous sûr de vouloir supprimer ce produit ?',
                  style: TextStyle(
                    fontSize: 30, // Taille du texte du titre
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Ferme le dialogue
                      },
                      child: Text(
                        'Non',
                        style: TextStyle(
                          fontSize: 25, // Taille du texte du bouton
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _productList.removeAt(index); // Supprime le produit
                        });
                        Navigator.of(context).pop(); // Ferme le dialogue
                      },
                      child: Text(
                        'Oui',
                        style: TextStyle(
                          fontSize: 25, // Taille du texte du bouton
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (_productList[index].quantity > 1) {
        _productList[index].quantity--;
      } else {
        _showDeleteConfirmationDialog(index); // Affiche le dialogue de confirmation
      }
    });
  }

  double _calculateTotal() {
    double total = 0;
    for (var product in _productList) {
      total += product.price * product.quantity;
    }
    return total;
  }
  void _registerSale(double total, double cashGiven, double change) async {
    var saleData = {
      "total_vente": total,
      "type_paiement": "Liquide", 
      "email_caissier": email_caissier,
      "date_vente": DateTime.now().toIso8601String(),
      "Monnaie_rendu": change,
      "articles": _productList.map((product) => {
        "code": product.Code,
        "nom": product.nom,
        "description": product.Description,
        "prix": product.price,
        "quantite": product.quantity
      }).toList()
    };

    var response = await http.post(
      Uri.parse(register_vente),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(saleData),
    );

    var jsonResponse = jsonDecode(response.body);

  }

  void _pay() {
    TextEditingController _cashController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Veuillez entrer le montant liquide présenté par le client :",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _cashController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 30,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Montant en €',
                  labelStyle: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Annuler",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                double total = _calculateTotal();
                double cashGiven = double.tryParse(_cashController.text) ?? 0;

                if (cashGiven >= total) {
                  double change = cashGiven - total;

                  Navigator.of(context).pop(); // Fermer le dialogue de saisie

                  // Afficher le dialogue de succès de paiement
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text(
                          cashGiven == total
                              ? "La vente a été payée avec succès !"
                              : "La vente a été payée avec succès !\nVoici la monnaie à rendre : ${change.toStringAsFixed(2)} €",
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Fermer le dialogue de succès de paiement

                              // Enregistrer la vente
                              _registerSale(total, cashGiven, change);

                              // Afficher le dialogue de succès de l'enregistrement de la vente
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Text(
                                      "La vente a été enregistrée avec succès !",
                                      style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _productList.clear();
                                          });
                                          Navigator.of(context).pop(); // Fermer le dialogue de succès de l'enregistrement de la vente
                                        },
                                        child: Text(
                                          "OK",
                                          style: TextStyle(
                                            fontSize: 27,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              "OK",
                              style: TextStyle(
                                fontSize: 27,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  double remainingAmount = total - cashGiven;

                  Navigator.of(context).pop(); // Fermer le dialogue de saisie

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text(
                          "Le montant présenté est insuffisant pour couvrir le total.\nMontant restant à payer : ${remainingAmount.toStringAsFixed(2)} €",
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Fermer le dialogue d'erreur
                            },
                            child: Text(
                              "OK",
                              style: TextStyle(
                                fontSize: 27,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text(
                "Valider",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
          ],
        );
      },
    );
  }



  void _cancelSale() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Annuler la vente',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir annuler la vente ?',
            style: TextStyle(
              fontSize: 27,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialogue
              },
              child: Text(
                'Non',
                style: TextStyle(
                  fontSize: 27,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _productList.clear(); // Vider la liste des produits
                });
                Navigator.of(context).pop(); // Fermer le dialogue
              },
              child: Text(
                'Oui',
                style: TextStyle(
                  fontSize: 27,
                ),
              ),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginPage()), // Assurez-vous que cette route est correcte
            );
          },
        ),
      ),
      body: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'Produits',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade700,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _productList.length,
                      itemBuilder: (context, index) {
                        final product = _productList[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.grey.shade500,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 32, // Taille du texte
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Code produit : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, // Titre en gras
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${product.Code},\n', // Nom du produit
                                    ),
                                    TextSpan(
                                      text: 'Nom produit : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, // Titre en gras
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${product.nom},\n', // Nom du produit
                                    ),
                                    TextSpan(
                                      text: 'Description : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, // Titre en gras
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${product.Description},\n' , // Description du produit
                                    ),
                                    TextSpan(
                                      text: 'Prix : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, // Titre en gras
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${product.price} €,\n', // Prix du produit
                                    ),
                                    TextSpan(
                                      text: 'Quantité: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, // Titre en gras
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${product.quantity}', // Quantité du produit
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                children: [
                                  SizedBox(
                                    width: 90,  // Largeur du bouton
                                    height: 90, // Hauteur du bouton
                                    child: IconButton(
                                      onPressed: () => _decreaseQuantity(index),
                                      icon: Icon(Icons.remove, color: Colors.black, size: 30), // Taille de l'icône
                                    ),
                                  ),
                                  SizedBox(
                                    width: 90,  // Largeur du bouton
                                    height: 90, // Hauteur du bouton
                                    child: IconButton(
                                      onPressed: () => _increaseQuantity(index),
                                      icon: Icon(Icons.add, color: Colors.black, size: 30), // Taille de l'icône
                                    ),
                                  ),
                                ],
                              )

                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Affichage du total et bouton "Payer"
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 42, // Augmenter la taille du texte
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Total: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '${_calculateTotal().toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _calculateTotal() > 0 ? _pay : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 54.0, vertical: 22.0), // Augmenter la taille du bouton
                            backgroundColor: _calculateTotal() > 0 ? Colors.indigo.shade100 : Colors.grey.shade600, // Changer la couleur du bouton
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: _calculateTotal() > 0 ? Colors.indigo.shade900 : Colors.grey.shade800, // Couleur de la bordure
                                width: 2.0, // Épaisseur de la bordure
                              ),
                            ),
                          ),
                          child: Text(
                            'Payer',
                            style: TextStyle(
                              fontSize: 42, // Taille du texte du bouton
                              color: Colors.black,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _calculateTotal() > 0 ? _cancelSale : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 45.0, vertical: 22.0),
                            backgroundColor: _calculateTotal() > 0 ? Colors.deepOrange.shade100 : Colors.grey.shade600, // Changer la couleur du bouton
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: _calculateTotal() > 0 ? Colors.deepOrange.shade600 : Colors.grey.shade800, // Couleur de la bordure
                                width: 2.0, // Épaisseur de la bordure
                              ),
                            ),
                          ),
                          child: Text(
                            'Annuler',
                            style: TextStyle(
                              fontSize: 42, // Taille du texte du bouton
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _input.isEmpty
                        ? 'Entrez le code à barre du produit'
                        : 'Le code à barre du produit : $_input',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 38, // Augmenter la taille du texte
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1.5,
                    ),
                    padding: const EdgeInsets.all(55.0),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      if (index < 10) {
                        return ElevatedButton(
                          onPressed: () {
                            _updateInput('$index');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.blueGrey.shade200,
                            side: BorderSide(
                                color: Colors.blueGrey.shade400, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$index',
                              style: TextStyle(
                                fontSize: 52,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      } else if (index == 10) {
                        return ElevatedButton(
                          onPressed: _clearInput,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.red.shade200,
                            side: BorderSide(
                                color: Colors.blueGrey.shade600, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 55,
                          ),
                        );
                      } else {
                        return ElevatedButton(
                          onPressed: _validateInput,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.green.shade200,
                            side: BorderSide(
                                color: Colors.blueGrey.shade600, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 55,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade300,
    );
  }
}
