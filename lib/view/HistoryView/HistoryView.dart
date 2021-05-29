import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/controllers/HistoryController.dart';
import 'package:green_heart/view/HistoryView/components/RecipeQuery.dart';
import 'package:green_heart/view/RecipeFeed/components/RecipeCard.dart';

class HistoryView extends StatefulWidget {
  @override
  _HistoryViewState createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  HistoryController c = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot>(
        stream: c.futureHistory,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> documents = snapshot.data.docs;
            List<dynamic> documentsMeal = List<dynamic>();
            documents.forEach((element) {
              documentsMeal.add(element['meal']);
            });
            return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  return recipeCard(documentsMeal, index);
                });
          } else if (snapshot.hasError) {
            return Text("Error " + snapshot.error.toString());
          }
          return CircularProgressIndicator();
        },
      ),
    ));
  }
}
