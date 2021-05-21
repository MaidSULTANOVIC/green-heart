import 'package:flutter/material.dart';

class RecipeView extends StatefulWidget {
  @override
  _RecipeViewState createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(child: Container(child: Text("RECIPE VIEW"))));
  }
}
