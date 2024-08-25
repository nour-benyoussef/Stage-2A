import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'Login.dart'; // Ensure this import points to your actual Login page class

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void registerUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showAlertDialog(context, "Erreur", "Veuillez remplir tous les champs.");
      return;
    }

    var reqBody = {
      "email": emailController.text,
      "Mot_De_Passe": passwordController.text
    };

    try {
      var response = await http.post(
        Uri.parse(register), // Add your registration URL here
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status']) {
          showAlertDialog(context, "Succès", "Admin enregistré avec succès !");
        } else {
          showAlertDialog(context, "Erreur", "Administrateur déja existant.");
        }
      } else {
        showAlertDialog(context, "Erreur", "Administrateur déja existant");
      }
    } catch (e) {
      print('Erreur lors de l\'inscription : $e');
      showAlertDialog(context, "Erreur", "Une erreur s'est produite : $e");
    }
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 20,
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
                Navigator.of(context).pop(); // Close the dialog
                if (title == "Succès") {
                  // Debug print statement
                  print("Navigating to LoginPage");

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage
                  );
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
      body: Stack(
        children: [
          // Image de fond floue
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/admin_login.jpg'), // Use same background image
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
                height: 580,
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
                      'assets/images/add-user.png', // Use same image or relevant one
                      height: 130,
                    ),
                    Text(
                      'Créer un Compte',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black, // Border color
                            width: 5.0, // Border width
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green.shade800, // Border color when focused
                            width: 2.0, // Border width
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
                            color: Colors.grey, // Border color
                            width: 2.0, // Border width
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green.shade800, // Border color when focused
                            width: 2.0, // Border width
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.green.shade200,
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'S\'inscrire',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()), // Navigate back to LoginPage
                        );
                      },
                      child: Text(
                        'Retour à la page de connexion',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700, // Change the color as needed
                          decoration: TextDecoration.underline, // Add underline for visual cue
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
