import 'package:flutter/material.dart';
import 'package:green_heart/models/Recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class RecipeFeedView extends StatefulWidget {
  @override
  _RecipeFeedViewState createState() => _RecipeFeedViewState();
}

class _RecipeFeedViewState extends State<RecipeFeedView> {
  Future<Recipe> _futureRecipe;

  @override
  void initState() {
    super.initState();
    _futureRecipe = fetchRecipe();
  }

  Future<Recipe> fetchRecipe() async {
    final response = await http.get(
      Uri.parse(
          'https://api.spoonacular.com/recipes/findByNutrients?apiKey=ed014e6f54164d6bbc778828ad05114c&minCalories=350&maxCalories=500&number=2'),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Recipe.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Recipe' + response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<Recipe>(
        future: _futureRecipe,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<dynamic> documents = snapshot.data.docs;
            return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  return Text(documents[index]['title']);
                });
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
