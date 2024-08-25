import 'package:flutter/material.dart';
import 'package:frontend_admin/products.dart';
import 'package:frontend_admin/sales.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cashiers.dart';
import 'dashboard.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({required this.token, Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    CashiersPage(),
    ProductsPage(),
    SalesPage(),
  ];

  final List<String> _titles = [
    'Tableau de bord', // This is displayed in the AppBar when DashboardPage is selected
    'Les caissiers',
    'Les articles',
    'Les ventes',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Redirect to login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Supprime la flèche de retour
        title: Center( // Center the title
          child: Text(
            _titles[_selectedIndex],
            style: TextStyle(
              fontSize: 35, // Increase font size
              fontWeight: FontWeight.bold, // Make text bold
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            iconSize: 40, // Increase icon size
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 300, // Set the width for the NavigationRail
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 2), // Border color and width
              color: Colors.white, // Background color for the container
            ),
            child: NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.selected,
              selectedIconTheme: IconThemeData(color: Colors.purple.shade700), // Highlight color for selected icon
              selectedLabelTextStyle: TextStyle(color: Colors.purple.shade800), // Highlight color for selected label
              destinations: [
                NavigationRailDestination(
                  icon: _buildNavIcon(Icons.dashboard),
                  selectedIcon: _buildNavIcon(Icons.dashboard_outlined),
                  label: _buildNavLabel('Tableau de bord'),
                ),
                NavigationRailDestination(
                  icon: _buildNavIcon(Icons.people),
                  selectedIcon: _buildNavIcon(Icons.people_outline),
                  label: _buildNavLabel('Les caissiers'),
                ),
                NavigationRailDestination(
                  icon: _buildNavIcon(Icons.shopping_bag),
                  selectedIcon: _buildNavIcon(Icons.shopping_bag_outlined),
                  label: _buildNavLabel('Les articles'),
                ),
                NavigationRailDestination(
                  icon: _buildNavIcon(Icons.sell),
                  selectedIcon: _buildNavIcon(Icons.sell_outlined),
                  label: _buildNavLabel('Les ventes'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding to space icons
      child: Icon(icon, size: 70), // Adjust icon size
    );
  }

  Widget _buildNavLabel(String label) {
    return SizedBox(
      width: 150, // Adjust width if necessary
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Adjust text size and weight
        ),
      ),
    );
  }
}
