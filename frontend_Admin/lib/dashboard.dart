import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_admin/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  int articleCount = 0;
  int VenteCount = 0;
  int CaissierCount = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.of(context).pop(); // Close the drawer after selection
    });
  }

  Future<void> fetchArticleCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse(totalArticle), // Assurez-vous que `totalArticle` est défini dans `config.dart`
        headers: {"Authorization": "Bearer $token"}, // Inclure le token dans l'en-tête
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          articleCount = jsonResponse['total'];
        });
        print('Nombre d\'articles : $articleCount');
      } else {
        print('Erreur lors de la récupération des articles : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des articles : $e');
    }
  }

  Future<void> fetchVenteCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse(totalVente), // Assurez-vous que `totalArticle` est défini dans `config.dart`
        headers: {"Authorization": "Bearer $token"}, // Inclure le token dans l'en-tête
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          VenteCount = jsonResponse['total'];
        });
        print('Nombre d\'ventes : $VenteCount');
      } else {
        print('Erreur lors de la récupération des articles : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des articles : $e');
    }
  }

  Future<void> fetchCaissierCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse(totalCaissier), // Assurez-vous que `totalArticle` est défini dans `config.dart`
        headers: {"Authorization": "Bearer $token"}, // Inclure le token dans l'en-tête
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          CaissierCount = jsonResponse['total'];
        });
        print('Nombre d\'Caissier : $CaissierCount');
      } else {
        print('Erreur lors de la récupération des articles : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des articles : $e');
    }
  }
  @override
  void initState() {
    super.initState();
    fetchArticleCount();
    fetchVenteCount();
    fetchCaissierCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Set the background color of the page
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 10.0), // Adjusted padding
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 10, // Spacing between columns
        mainAxisSpacing: 10, // Spacing between rows
        children: [
          _buildCard('Articles', articleCount.toString(), Icons.article, Colors.blue.shade100),
          _buildCard('Ventes', VenteCount.toString(), Icons.attach_money, Colors.green.shade100),
          _buildCard('Caissiers', CaissierCount.toString(), Icons.person, Colors.orange.shade100),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String count, IconData icon, Color color) {
    return Card(
      color: color,
      elevation: 5,
      child: Center(
        child: ListTile(
          leading: Icon(icon, size: 60, color: Colors.grey[800]), // Adjusted icon color
          title: Text(
            title,
            style: TextStyle(fontSize: 37, fontWeight: FontWeight.bold, color: Colors.grey[800]), // Adjusted title color
          ),
          subtitle: Text(
            count,
            style: TextStyle(fontSize: 37, fontWeight: FontWeight.bold, color: Colors.grey[800]), // Adjusted count color
          ),
        ),
      ),
    );
  }
}
