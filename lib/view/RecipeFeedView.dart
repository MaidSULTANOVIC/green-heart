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
          'https://api.spoonacular.com/recipes/complexSearch?apiKey=ed014e6f54164d6bbc778828ad05114c&diet=vegetarian&minCalories=350&maxCalories=500&number=3'),
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
    return SafeArea(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 15.0),
              child: Text("Hi, Paul!",
                  style: TextStyle(
                      color: Color(0xFF36DC55),
                      fontSize: 25.0,
                      fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: Text("Your recipes",
                  style: TextStyle(
                      color: Color(0xFF2D2F30),
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600)),
            ),
            FutureBuilder<Recipe>(
              future: _futureRecipe,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<dynamic> documents = snapshot.data.docs;
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        return Container(
                            height: 160.0,
                            margin: const EdgeInsets.only(
                              top: 16.0,
                              bottom: 10.0,
                              left: 15.0,
                              right: 15.0,
                            ),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(documents[index]['image']),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0xFF36DC55),
                            ),
                            child: InkWell(
                              onTap: () => print("tapped"),
                              borderRadius: BorderRadius.circular(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                      width: 500.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color(0xAA6C6C6C),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            documents[index]['title'],
                                            style:
                                                TextStyle(color: Colors.white),
                                            softWrap: true,
                                          ),
                                          Text(
                                              (documents[index]['nutrition']
                                                              ['nutrients'][0]
                                                          ['amount'])
                                                      .toInt()
                                                      .toString() +
                                                  'kCal',
                                              style: TextStyle(
                                                  color: Color(0xFF36DC55))),
                                        ],
                                      )),
                                ],
                              ),
                            ));
                      });
                } else if (snapshot.hasError) {
                  return SafeArea(child: Text("${snapshot.error}"));
                }

                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
