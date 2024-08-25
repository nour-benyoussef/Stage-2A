import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_admin/config.dart'; // Assurez-vous que le chemin est correct
import 'package:intl/intl.dart';

class CashiersPage extends StatefulWidget {
  @override
  _CashiersPageState createState() => _CashiersPageState();
}

class _CashiersPageState extends State<CashiersPage> {
  List<Map<String, String>> cashiers = [];
  List<Map<String, String>> filteredCashiers = [];
  bool isLoading = true;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final _formKey = GlobalKey<FormState>();

  // Variables pour les champs du formulaire
  String _nom = '';
  String _prenom = '';
  String _email = '';
  String _motDePasse = '';
  String _telephone = '';
  DateTime _dateEmbauche = DateTime.now();
  double _salaire = 0.0; // Assurez-vous que _salaire est de type double

  @override
  void initState() {
    super.initState();
    fetchCashiers();
  }

  Future<void> fetchCashiers() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      final response = await http.get(
        Uri.parse(AllCaissiers),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        List<dynamic> data = jsonResponse['caissiers'];

        setState(() {
          cashiers = List<Map<String, String>>.from(
            data.map((item) {
              String formattedDate = '';
              try {
                DateTime date = DateTime.parse(item['date_embauche']);
                formattedDate = dateFormat.format(date);
              } catch (e) {
                formattedDate = 'Inconnu';
              }

              return {
                'nom': item['nom']?.toString() ?? '',
                'prenom': item['prenom']?.toString() ?? '',
                'email': item['email']?.toString() ?? '',
                'telephone': item['telephone']?.toString() ?? '',
                'date_embauche': formattedDate,
                'salaire': item['Salaire']?.toString() ?? '',
                'id': item['id']?.toString() ?? '',
              };
            }),
          );
          filteredCashiers = List.from(cashiers);
          isLoading = false;
        });
      } else {
        print('Erreur lors de la récupération des caissiers : ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération des caissiers : $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterCashiers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCashiers = List.from(cashiers);
      } else {
        filteredCashiers = cashiers.where((cashier) {
          return cashier['nom']!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }




  void onEditPressed(String email) async {
    final String apiUrl = getCaissier+ '/$email';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['caissier']; // Assurez-vous que 'caissier' est la clé correcte

        // Vérifiez si data est null
        if (data == null) {
          print('Les données du caissier sont nulles.');
          return;
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                child: Text(
                  'Modifier un Caissier',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
              content: Container(
                width: 500,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          initialValue: data['email'] ?? '', // Email non modifiable
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          onSaved: (value) {
                            _email = data['email'] ;
                          },
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
                          initialValue: data['prenom'] ?? '',
                          decoration: InputDecoration(
                            labelText: 'Prénom',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le prénom';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _prenom = value ?? '';
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          initialValue: data['telephone']?.toString() ?? '', // Convertir en String
                          decoration: InputDecoration(
                            labelText: 'Téléphone',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le téléphone';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _telephone = value ?? '';
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          initialValue: data['dateEmbauche'] != null
                              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(data['dateEmbauche']))
                              : '', // Convertir en String
                          decoration: InputDecoration(
                            labelText: 'Date d\'embauche',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          enabled: false, // Date d'embauche non modifiable
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          initialValue: data['Salaire'] != null ? data['Salaire'].toString() : '',
                          decoration: InputDecoration(
                            labelText: 'Salaire',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le salaire';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _salaire = double.tryParse(value ?? '') ?? 0.0; // Assurez-vous que _salaire est de type double
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
                        final response = await http.put(
                          Uri.parse(updateCaissier),
                          headers: {
                            "Authorization": "Bearer $token",
                            "Content-Type": "application/json",
                          },
                          body: jsonEncode({
                            'nom': _nom,
                            'prenom': _prenom,
                            'email':_email,
                            'telephone': _telephone,
                            'Salaire': _salaire,
                          }),
                        );
                        if (response.statusCode == 400) {
                          print('Erreur 400 : ${response.body}'); // Afficher le corps de la réponse pour plus d'informations
                        }
                        if (response.statusCode == 200) {
                          Navigator.of(context).pop(); // Fermer le premier dialogue

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text(
                                  'Caissier modifié avec succès.',
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
                                      fetchCashiers(); // Rafraîchir la liste des caissiers
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          print('Erreur lors de la modification du caissier : ${response.statusCode}');
                          Navigator.of(context).pop();

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text('Erreur lors de la modification du caissier.'),
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
                        print('Erreur lors de la modification du caissier : $e');
                        Navigator.of(context).pop();

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Text('Erreur lors de la modification du caissier.'),
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
        print('Erreur lors de la récupération des informations du caissier : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des informations du caissier : $e');
    }
  }




  void onDeletePressed(String id) async {
    final String apiUrl = deleteCaissier +'/$id'; // Remplacez par l'URL de votre API

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
                content: Text('Caissier supprimé avec succès.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Fermer le dialogue
                      // Rafraîchir la liste des caissiers ou effectuer une autre action
                      fetchCashiers(); // Exemple de méthode pour mettre à jour l'interface
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
                content: Text('Erreur lors de la suppression du caissier.'),
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
              content: Text('Erreur lors de la suppression du caissier.'),
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
      print('Erreur lors de la suppression du caissier : $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Erreur lors de la suppression du caissier.'),
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
              'Ajouter un Caissier',
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
                        labelText: 'Nom',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold, // Titre en gras
                          fontSize: 20, // Augmenter la taille des titres des champs
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
                    SizedBox(height: 10), // Espacement entre les champs
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Prénom',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le prénom';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _prenom = value ?? '';
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer l\'email';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value ?? '';
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      obscureText: true, // Masquer le mot de passe
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le mot de passe';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _motDePasse = value ?? '';
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Téléphone',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le téléphone';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _telephone = value ?? '';
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Salaire',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le salaire';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _salaire = double.tryParse(value ?? '') ?? 0.0; // Convertit la chaîne en double
                      },
                    ),
                    SizedBox(height: 10),
                    // Date picker for date of hire
                    ListTile(
                      title: Text(
                        'Date d\'embauche',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text(dateFormat.format(_dateEmbauche)),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _dateEmbauche,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null && pickedDate != _dateEmbauche) {
                          setState(() {
                            _dateEmbauche = pickedDate;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Annuler',
                style: TextStyle(
                  fontWeight: FontWeight.bold, // Mettre le texte en gras
                  fontSize: 22, // Augmenter la taille de la police du bouton
                ),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter',  style: TextStyle(
                fontWeight: FontWeight.bold, // Mettre le texte en gras
                fontSize: 22, // Augmenter la taille de la police du bouton
              ),),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  // Envoyer la requête POST
                  try {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String? token = prefs.getString('token');

                    final response = await http.post(
                      Uri.parse(AddCaissier), // URL de l'API pour ajouter un caissier
                      headers: {
                        "Authorization": "Bearer $token",
                        "Content-Type": "application/json",
                      },
                      body: jsonEncode({
                        'nom': _nom,
                        'prenom': _prenom,
                        'email': _email,
                        'Mot_De_Passe': _motDePasse, // Assurez-vous que le nom de la clé correspond à ce que l'API attend
                        'telephone': _telephone,
                        'date_embauche': dateFormat.format(_dateEmbauche),
                        'Salaire': _salaire,
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
                              'Caissier ajouté avec succès.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30, // Augmenter la taille de la police du contenu
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, // Mettre le texte en gras
                                    fontSize: 22, // Augmenter la taille de la police du bouton
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Fermer le dialogue de succès
                                  fetchCashiers(); // Rafraîchir la liste des caissiers
                                },
                              ),
                            ],
                          );

                        },
                      );
                    } else if (response.statusCode == 409) { // Code de conflit, indiquant que le caissier existe déjà
                      Navigator.of(context).pop(); // Fermer le formulaire

                      // Afficher le dialogue d'erreur
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text('Un caissier avec cet email existe déjà.'),
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
                      print('Erreur lors de l\'ajout du caissier : ${response.statusCode}');
                      Navigator.of(context).pop(); // Fermer le formulaire

                      // Afficher le dialogue d'erreur général
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content:  Text(
                            'Un caissier avec cet email existe déjà.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30, // Augmenter la taille de la police du contenu
                            ),
                          ),
                            actions: [
                              TextButton(
                                child: Text('OK',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22, // Augmenter la taille de la police du contenu
                                    )),
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
                    print('Erreur lors de l\'ajout du caissier : $e');
                    Navigator.of(context).pop(); // Fermer le formulaire

                    // Afficher le dialogue d'erreur général
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text('Caissier Déja existant.'),
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
        color: Colors.grey[200],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: 700,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Rechercher par nom',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: filterCashiers,
                    ),
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.green, size: 35),
                    onPressed: onAddPressed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
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
                      0: FixedColumnWidth(200),
                      1: FixedColumnWidth(200),
                      2: FixedColumnWidth(200),
                      3: FixedColumnWidth(200),
                      4: FixedColumnWidth(200),
                      5: FixedColumnWidth(200),
                      6: FixedColumnWidth(170),
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
                                  'Prénom',
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
                                  'Email',
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
                                  'Téléphone',
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
                                  'Date d\'embauche',
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
                                  'Salaire',
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
                      ...filteredCashiers.map((cashier) {
                        return TableRow(
                          children: [
                            TableCell(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(cashier['nom']!, style: TextStyle(fontSize: 22))),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(cashier['prenom']!, style: TextStyle(fontSize: 22))),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(cashier['email']!, style: TextStyle(fontSize: 22))),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(cashier['telephone']!, style: TextStyle(fontSize: 22))),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(cashier['date_embauche']!, style: TextStyle(fontSize: 22))),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(cashier['salaire']!, style: TextStyle(fontSize: 22))),
                            )),
                            TableCell(
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue, size: 35),
                                      onPressed: () => onEditPressed(cashier['email'] ?? ''),
                                    ),
                                    SizedBox(width: 16),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red, size: 35),
                                      onPressed: () => onDeletePressed(cashier['email'] ?? ''),
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
