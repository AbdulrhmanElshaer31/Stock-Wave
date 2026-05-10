import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _HomeState();
}

class _HomeState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("This is Search Page"));
  }
}
