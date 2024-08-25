import 'package:caisse/home.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Login.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(token: prefs.getString('token') ?? '')); // Provide a default empty string if token is null
}

class MyApp extends StatelessWidget {
  final String token;

  const MyApp({required this.token, Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: (token.isNotEmpty && !JwtDecoder.isExpired(token))
          ? HomePage(token: token)
          : LoginPage(),
    );
  }
}
