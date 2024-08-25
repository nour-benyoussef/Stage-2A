import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_admin/config.dart'; // Assurez-vous que le chemin est correct
import 'package:intl/intl.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  bool isLoading = true;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd'); // Créez un formatteur de date si nécessaire
// Variables pour les champs du formulaire
  final _formKey = GlobalKey<FormState>();

  String _code = '';
  String _nom = '';
  String _description = '';
  String _prix = '';
  String _stock = '';
  String _categorie = '';
  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      final response = await http.get(
        Uri.parse(AllProducts), // Assurez-vous que `AllProducts` est défini dans `config.dart`
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        List<dynamic> data = jsonResponse['articles']; // Ajustez selon la structure de la réponse

        setState(() {
          products = List<Map<String, dynamic>>.from(
            data.map((item) {
              return {
                'code': item['code']?.toString() ?? '',
                'nom': item['nom']?.toString() ?? '',
                'description': item['description']?.toString() ?? '',
                'prix': item['prix']?.toString() ?? '',
                'stock': item['stock']?.toString() ?? '',
                'categorie': item['categorie']?.toString() ?? '',
                'id': item['id']?.toString() ?? '', // Assurez-vous d'inclure l'ID pour les actions
              };
            }),
          );
          filteredProducts = List.from(products);
          isLoading = false;
        });
      } else {
        // Gérer les erreurs de réponse
        print('Erreur lors de la récupération des produits : ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Gérer les exceptions
      print('Erreur lors de la récupération des produits : $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = List.from(products);
      } else {
        filteredProducts = products.where((product) {
          return product['code']!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }


  void onEditPressed(String code) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(getArticle +'/$code'), // Assurez-vous que getArticle est correctement défini
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['article']; // Assurez-vous que 'article' est la clé correcte

        // Vérifiez si data est null
        if (data == null) {
          print('Les données du produit sont nulles.');
          return;
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                child: Text(
                  'Modifier un Produit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
              content: Container(
                width: 700,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          initialValue: data['code'], // Pré-remplir avec le code actuel
                          decoration: InputDecoration(
                            labelText: 'Code',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          enabled: false,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          initialValue: data['nom'] ?? '',
                          decoration: InputDecoration(
                            labelText: 'Nom',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _nom = value ?? '';
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          initialValue: data['description'] ?? '',
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la description';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _description = value ?? '';
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          initialValue: data['prix']?.toString() ?? '',
                          decoration: InputDecoration(
                            labelText: 'Prix',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le prix';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _prix = value ?? '';
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          initialValue: data['stock']?.toString() ?? '',
                          decoration: InputDecoration(
                            labelText: 'Stock',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le stock';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _stock = value ?? '';
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          initialValue: data['categorie'] ?? '',
                          decoration: InputDecoration(
                            labelText: 'Catégorie',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la catégorie';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _categorie = value ?? '';
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    'Sauvegarder',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      try {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String? token = prefs.getString('token');

                        final response = await http.put(
                          Uri.parse(updateArticle),
                          headers: {
                            "Authorization": "Bearer $token",
                            "Content-Type": "application/json",
                          },
                          body: jsonEncode({
                            'code': data['code'],
                            'nom': _nom,
                            'description': _description,
                            'prix': _prix,
                            'stock': _stock,
                            'categorie': _categorie,
                          }),
                        );

                        if (response.statusCode == 200) {
                          Navigator.of(context).pop(); // Fermer le premier dialogue

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text(
                                  'Produit modifié avec succès.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      'OK',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      fetchProducts(); // Rafraîchir la liste des produits
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          print('Erreur lors de la modification du produit : ${response.statusCode}');
                          Navigator.of(context).pop();

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text('Erreur lors de la modification du produit.'),
                                actions: [
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } catch (e) {
                        print('Erreur lors de la modification du produit : $e');
                        Navigator.of(context).pop();

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Text('Erreur lors de la modification du produit.'),
                              actions: [
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      } else {
        print('Erreur lors de la récupération des informations du produit : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des informations du produit : $e');
    }
  }



  void onDeletePressed(String id) async {
    final String apiUrl = deleteArticle + '/$id'; // Remplacez par l'URL de votre API

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          // Ajoutez ici d'autres en-têtes si nécessaire, par exemple pour l'authentification
        },
      );

      if (response.statusCode == 200) {
        // Suppression réussie
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          // Afficher un message de succès
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text('Article supprimé avec succès.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Fermer le dialogue
                      // Rafraîchir la liste des articles ou effectuer une autre action
                      fetchProducts(); // Exemple de méthode pour mettre à jour l'interface
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // Afficher un message d'erreur
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text('Erreur lors de la suppression de l\'article.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Fermer le dialogue
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        // Erreur HTTP (par exemple, 404 ou 500)
        print('Erreur HTTP lors de la suppression : ${response.statusCode}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('Erreur lors de la suppression de l\'article.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer le dialogue
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Erreur de réseau ou autre
      print('Erreur lors de la suppression de l\'article : $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Erreur lors de la suppression de l\'article.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer le dialogue
                },
              ),
            ],
          );
        },
      );
    }
  }

  void onAddPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Ajouter un Produit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30, // Augmenter la taille de la police du titre
              ),
            ),
          ),
          content: Container(
            width: 700, // Ajuster la largeur ici
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Code',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le code';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _code = value ?? '';
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nom';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _nom = value ?? '';
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la description';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _description = value ?? '';
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Prix',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le prix';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _prix = value ?? '';
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Stock',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le stock';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _stock = value ?? '';
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Catégorie',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la catégorie';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _categorie = value ?? '';
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Annuler',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Ajouter',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  // Envoyer la requête POST
                  try {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String? token = prefs.getString('token');

                    final response = await http.post(
                      Uri.parse(AddArticle), // URL de l'API pour ajouter un produit
                      headers: {
                        "Authorization": "Bearer $token",
                        "Content-Type": "application/json",
                      },
                      body: jsonEncode({
                        'code': _code,
                        'nom': _nom,
                        'description': _description,
                        'prix': _prix,
                        'stock': _stock,
                        'categorie': _categorie,
                      }),
                    );

                    if (response.statusCode == 200) { // Code de succès pour création
                      Navigator.of(context).pop(); // Fermer le premier dialogue

                      // Afficher le dialogue de succès
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(
                              'Produit ajouté avec succès.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Fermer le dialogue de succès
                                  fetchProducts(); // Rafraîchir la liste des produits
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else if (response.statusCode == 409) { // Code de conflit, indiquant que le produit existe déjà
                      Navigator.of(context).pop(); // Fermer le formulaire

                      // Afficher le dialogue d'erreur
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text('Un produit avec ce code existe déjà.'),
                            actions: [
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Fermer le dialogue d'erreur
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      print('Erreur lors de l\'ajout du produit : ${response.statusCode}');
                      Navigator.of(context).pop(); // Fermer le formulaire

                      // Afficher le dialogue d'erreur général
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(
                              'Un produit avec ce code existe déjà.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Fermer le dialogue d'erreur
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } catch (e) {
                    print('Erreur lors de l\'ajout du produit : $e');
                    Navigator.of(context).pop(); // Fermer le formulaire

                    // Afficher le dialogue d'erreur général
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text('Erreur lors de l\'ajout du produit.'),
                          actions: [
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop(); // Fermer le dialogue d'erreur
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[200], // Couleur de fond grise
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barre de recherche avec icône d'ajout
            Container(
              width: 700, // Utiliser la largeur maximale
              child: Row(
                children: [
                  // Barre de recherche avec fond blanc
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Rechercher par code',
                        border: OutlineInputBorder(),
                        filled: true, // Définit le champ comme rempli
                        fillColor: Colors.white, // Couleur de fond blanc
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: filterProducts,
                    ),
                  ),
                  SizedBox(width: 20), // Espacement entre la barre de recherche et l'icône d'ajout
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.green, size: 35),
                    onPressed: onAddPressed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Espacement entre la barre de recherche et le tableau
            // Tableau avec cadre
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), // Coins arrondis
                ),
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(
                      color: Colors.grey.shade600,
                      width: 2,
                    ),
                    columnWidths: {
                      0: FixedColumnWidth(150),
                      1: FixedColumnWidth(200),
                      2: FixedColumnWidth(250),
                      3: FixedColumnWidth(150),
                      4: FixedColumnWidth(150),
                      5: FixedColumnWidth(200),
                      6: FixedColumnWidth(200),
                      7: FixedColumnWidth(240),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                        ),
                        children: [
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Code',
                                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Nom',
                                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Description',
                                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Prix',
                                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Stock',
                                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Catégorie',
                                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  '',
                                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...filteredProducts.map((product) {
                        return TableRow(
                          children: [
                            TableCell(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(product['code']!, style: TextStyle(fontSize: 22))),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(product['nom']!, style: TextStyle(fontSize: 22))),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(product['description']!, style: TextStyle(fontSize: 22))),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(product['prix']!, style: TextStyle(fontSize: 22))),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(product['stock']!, style: TextStyle(fontSize: 22))),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(product['categorie']!, style: TextStyle(fontSize: 22))),
                            )),
                            TableCell(
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue, size: 35),
                                      onPressed: () => onEditPressed(product['code'] ?? ''),
                                    ),
                                    SizedBox(width: 16), // Espacement entre les boutons
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red, size: 35),
                                      onPressed: () => onDeletePressed(product['code'] ?? ''),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
