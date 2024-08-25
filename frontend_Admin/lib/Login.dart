import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend_admin/config.dart';
import 'package:frontend_admin/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Home.dart'; // Assurez-vous que le chemin est correct pour votre projet

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController identifiantController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences prefs;
  var myToken;

  @override
  void initState() {
    super.initState();
    initSharedPref();
    myToken = 0;
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> showAlertDialog(BuildContext context, String title, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "OK",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialogue
              },
            ),
          ],
        );
      },
    );
  }

  void loginUser() async {
    if (identifiantController.text.isEmpty || passwordController.text.isEmpty) {
      showAlertDialog(context, "Erreur", "Veuillez remplir tous les champs.");
      return;
    }

    var reqBody = {
      "email": identifiantController.text,
      "Mot_De_Passe": passwordController.text
    };

    try {
      var response = await http.post(
        Uri.parse(login), // Assurez-vous que `login` est défini dans `config.dart`
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status']) {
          myToken = jsonResponse['token'];
          prefs.setString('token', myToken);

          String message = "Bonjour,\n"
              "Bienvenue ! Vous êtes maintenant connecté(e) en tant qu'administrateur.\n"
              "Bon travail Aujourd'hui !";

          // Montrer le dialogue et naviguer après fermeture
          showAlertDialog(context, "Connexion Réussie", message).then((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage(token: myToken)),
            );
          });
        } else {
          showAlertDialog(context, "Erreur", "Identifiant ou mot de passe incorrect.");
        }
      } else {
        showAlertDialog(context, "Erreur", "Identifiant ou mot de passe incorrect.");
      }
    } catch (e, stackTrace) {
      print('Erreur lors de la connexion : $e');
      print('Stack trace: $stackTrace');
      showAlertDialog(context, "Erreur", "Une erreur s'est produite : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond floue
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/admin_login.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          // Formulaire centré
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 800,
                height: 570,
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/authorization.png',
                      height: 130,
                    ),
                    Text(
                      'Connexion Administrateur',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: identifiantController,
                      decoration: InputDecoration(
                        labelText: 'Identifiant',
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black, // Couleur du bord
                            width: 5.0, // Largeur du bord
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green.shade800, // Couleur du bord quand le champ est focus
                            width: 2.0, // Largeur du bord
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mot de Passe',
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey, // Couleur du bord
                            width: 2.0, // Largeur du bord
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green.shade800, // Couleur du bord quand le champ est focus
                            width: 2.0, // Largeur du bord
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    OutlinedButton(
                      onPressed: loginUser,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                        backgroundColor: Colors.green.shade200,
                        side: BorderSide(
                          color: Colors.green.shade800,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        "Vous n'avez pas de compte ? Créez-en un ici.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
