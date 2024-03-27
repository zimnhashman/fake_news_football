import 'dart:convert';
import 'package:fake_news_football/screens/news_check_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NewsCheckScreen(),
        debugShowCheckedModeBanner: false,
    );
  }
}

