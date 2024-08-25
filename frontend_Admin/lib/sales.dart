import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_admin/config.dart'; // Assurez-vous que le chemin est correct
import 'package:intl/intl.dart';

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<Map<String, dynamic>> sales = [];
  bool isLoading = true;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    fetchSales();
  }

  Future<void> fetchSales() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      final response = await http.get(
        Uri.parse(AllVentes), // Assurez-vous que `AllVentes` est défini dans `config.dart`
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        List<dynamic> data = jsonResponse['ventes']; // Ajustez selon la structure de la réponse

        setState(() {
          sales = List<Map<String, dynamic>>.from(
            data.map((item) {
              return {
                'total_vente': item['total_vente']?.toString() ?? '',
                'type_paiement': item['type_paiement']?.toString() ?? '',
                'email_caissier': item['email_caissier']?.toString() ?? '',
                'date_vente': dateFormat.format(DateTime.parse(item['date_vente'])),
                'Monnaie_rendu': item['Monnaie_rendu']?.toString() ?? '',
                'articles': List<Map<String, dynamic>>.from(
                  item['articles']?.map((article) {
                    return {
                      'code': article['code']?.toString() ?? '',
                      'nom': article['nom']?.toString() ?? '',
                      'description': article['description']?.toString() ?? '',
                      'prix': article['prix']?.toString() ?? '',
                      'quantite': article['quantite']?.toString() ?? '',
                    };
                  }) ?? [],
                ),
              };
            }),
          );
          isLoading = false;
        });
      } else {
        // Gérer les erreurs de réponse
        print('Erreur lors de la récupération des ventes : ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Gérer les exceptions
      print('Erreur lors de la récupération des ventes : $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[200], // Couleur de fond grise
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Supprimer la barre de recherche
            const SizedBox(height: 20), // Espacement entre la barre de recherche et le tableau
            // Tableau avec cadre
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(
                    color: Colors.grey.shade600,
                    width: 2,
                  ),
                  columnWidths: {
                    0: FixedColumnWidth(200),
                    1: FixedColumnWidth(220),
                    2: FixedColumnWidth(220),
                    3: FixedColumnWidth(200),
                    4: FixedColumnWidth(220),
                    5: FixedColumnWidth(300),
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
                                'Total Vente',
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
                                'Type Paiement',
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
                                'Email Caissier',
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
                                'Date Vente',
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
                                'Monnaie Rendu',
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
                                'Articles',
                                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...sales.map((sale) {
                      return TableRow(
                        children: [
                          TableCell(child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text(sale['total_vente']!, style: TextStyle(fontSize: 22))),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text(sale['type_paiement']!, style: TextStyle(fontSize: 22))),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text(sale['email_caissier']!, style: TextStyle(fontSize: 22))),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text(sale['date_vente']!, style: TextStyle(fontSize: 22))),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text(sale['Monnaie_rendu']!, style: TextStyle(fontSize: 22))),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...sale['articles'].map((article) {
                                  return Text(
                                    '${article['nom']} [ ${article['quantite']} * ${article['prix']} € ]',
                                    style: TextStyle(fontSize: 22),
                                  );
                                }).toList(),
                              ],
                            )),
                          )),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
