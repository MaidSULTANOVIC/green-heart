import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/controllers/RecipeController.dart';
import 'package:green_heart/models/Ingredients.dart';
import 'package:green_heart/models/Instructions.dart';
import 'package:green_heart/view/RecipeView/components/Ingredient.dart';

import 'components/Instruction.dart';

class RecipeView extends StatefulWidget {
  RecipeView(this.mealId);

  final int mealId;

  @override
  _RecipeViewState createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  RecipeController c = Get.put(RecipeController());

  @override
  void initState() {
    c.initFuture(widget.mealId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      child: Column(
        children: [
          Text("Ingredients"),
          SizedBox(height: 15.0),
          Container(
            height: 120.0,
            child: FutureBuilder<Ingredients>(
              future: c.futureIngredients,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<dynamic> documents = snapshot.data.ingredients;
                  return ListView.separated(
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(width: 3);
                      },
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: false,
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        return Ingredient(documents, index);
                      });
                } else if (snapshot.hasError) {
                  return SafeArea(child: Text("${snapshot.error}"));
                }

                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
          ),
          SizedBox(height: 25.0),
          Text("Instructions"),
          SizedBox(height: 25.0),
          Container(
            height: 120.0,
            child: FutureBuilder<Instructions>(
              future: c.futureInstructions,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<dynamic> documents = snapshot.data.instructions;
                  return ListView.separated(
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(height: 25);
                      },
                      scrollDirection: Axis.vertical,
                      shrinkWrap: false,
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        return Instruction(documents, index);
                      });
                } else if (snapshot.hasError) {
                  return SafeArea(child: Text("${snapshot.error}"));
                }

                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    )));
  }
}
