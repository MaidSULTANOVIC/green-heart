import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/controllers/RecipeFeedController.dart';
import 'package:green_heart/models/Recipe.dart';
import 'package:green_heart/view/RecipeFeed/components/RecipeCard.dart';

class RecipeFeedView extends StatefulWidget {
  @override
  _RecipeFeedViewState createState() => _RecipeFeedViewState();
}

class _RecipeFeedViewState extends State<RecipeFeedView> {
  RecipeFeedController c = Get.put(RecipeFeedController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 15.0),
                child: Text("Hi, Paul! ",
                    style: TextStyle(
                        color: Color(0xFF36DC55),
                        fontSize: 25.0,
                        fontWeight: FontWeight.w600)),
              ),
              FlatButton(
                  onPressed: () {
                    c.fetchData();
                    c.disconnect();
                  },
                  child: Icon(Icons.dangerous)),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                child: Text("Your recipes",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600)),
              ),
              FutureBuilder<Recipe>(
                future: c.futureRecipe,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List<dynamic> documents = snapshot.data.docs;
                    return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          return recipeCard(documents, index);
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
      ),
    );
  }
}
