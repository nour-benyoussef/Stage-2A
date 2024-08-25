import 'dart:convert';
import 'dart:ui'; // Importer pour BackdropFilter
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart'; // Assurez-vous que cette importation pointe vers la bonne page d'accueil
import 'package:http/http.dart' as http;
import 'config.dart'; // Importez votre fichier de configuration

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

  Future<void> showAlertDialog(BuildContext context, String title, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "OK",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
        Uri.parse(login), // Assurez-vous que 'login' pointe vers l'URL correcte dans 'config.dart'
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status']) {
        myToken = jsonResponse['token'];
        prefs.setString('token', myToken);

        String message = "Bonjour ${jsonResponse['prenom']} ${jsonResponse['nom']},\n"
            "Bienvenue ! Vous êtes maintenant connecté(e) en tant que caissier(e)\n "
            "Bon travail Aujourd'hui !";

        await showAlertDialog(context, "Connexion Réussie", message);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(token: myToken)),
        );
      } else {
        showAlertDialog(context, "Erreur", "Identifiant ou mot de passe incorrect.");
      }
    } catch (e) {
      print('Erreur lors de la connexion : $e');
      showAlertDialog(context, "Erreur", "Une erreur s'est produite : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond floue
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/5594016.jpg'), // Assurez-vous que l'image existe à cet emplacement
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Applique l'effet de flou
              child: Container(
                color: Colors.black.withOpacity(0.2), // Couleur de superposition légèrement opaque
              ),
            ),
          ),
          // Conteneur de connexion au-dessus de l'image de fond
          Center(
            child: Container(
              width: 700, // Largeur du cadre de connexion
              height: 500,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 3), // Décalage du cadre
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    'assets/images/caissier_login.png', // Assurez-vous que l'image existe à cet emplacement
                    height: 150, // Ajuster la taille de l'image
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Accédez à Votre Caisse en un Clic!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30, // Ajuster la taille de la police
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: identifiantController,
                    decoration: InputDecoration(
                      labelText: 'Identifiant',
                      labelStyle: const TextStyle(color: Colors.black87, fontSize: 16),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black87, width: 1.5),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de Passe',
                      labelStyle: const TextStyle(color: Colors.black87, fontSize: 16),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black87, width: 1.5),
                      ),
                    ),
                    obscureText: true,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, // Couleur du texte
                      backgroundColor: Colors.green.shade300, // Couleur de fond
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      side: BorderSide(
                        color: Colors.green.shade700,
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
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
