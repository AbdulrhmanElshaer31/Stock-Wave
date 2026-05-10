import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF111111),
          elevation: 2,
          title: const Text(
            "Home",
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(color: Colors.black),
          child: const Center(
            child: Text(
              "This is Home Page",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
