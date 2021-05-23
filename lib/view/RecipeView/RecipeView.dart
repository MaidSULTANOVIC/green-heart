import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/controllers/RecipeController.dart';
import 'package:green_heart/models/Ingredients.dart';
import 'package:green_heart/models/Instructions.dart';
import 'package:green_heart/view/RecipeView/components/Ingredient.dart';

import 'components/Instruction.dart';

class RecipeView extends StatefulWidget {
  RecipeView(this.meal, this.index);

  final List<dynamic> meal;
  final int index;

  @override
  _RecipeViewState createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  RecipeController c = Get.put(RecipeController());

  @override
  void initState() {
    c.initFuture(widget.meal[widget.index]['id']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          centerTitle: true,
          title: Text(widget.meal[widget.index]['title'],
              style: TextStyle(color: Colors.black)),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  color: Colors.black,
                ),
                onPressed: () => c.printInfo()),
          ],
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.network(
                    widget.meal[widget.index]['image'],
                    filterQuality: FilterQuality.high,
                  ),
                ),
                SizedBox(height: 25.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    child: Text("Ingredients",
                        style: TextStyle(
                          color: Color(0xFF36DC55),
                          fontSize: 25.0,
                        )),
                    alignment: Alignment.centerLeft,
                  ),
                ),
                SizedBox(height: 15.0),
                Container(
                  height: 120.0,
                  child: FutureBuilder<Ingredients>(
                    future: c.futureIngredients,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final List<dynamic> documents =
                            snapshot.data.ingredients;
                        return ListView.separated(
                            separatorBuilder:
                                (BuildContext context, int index) {
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Instructions",
                        style: TextStyle(
                          color: Color(0xFF36DC55),
                          fontSize: 25.0,
                        )),
                  ),
                ),
                SizedBox(height: 25.0),
                FutureBuilder<Instructions>(
                  future: c.futureInstructions,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<dynamic> documents =
                          snapshot.data.instructions;
                      return ListView.separated(
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(height: 25);
                          },
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
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
              ],
            ),
          ),
        )));
  }
}
