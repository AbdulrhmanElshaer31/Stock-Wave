import 'package:flutter/material.dart';

class Market extends StatefulWidget {
  const Market({super.key});

  @override
  State<Market> createState() => _HomeState();
}

class _HomeState extends State<Market> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("This is Market Page"));
  }
}
