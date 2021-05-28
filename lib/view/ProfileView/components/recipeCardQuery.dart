import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/controllers/RecipeFeedController.dart';
import 'package:green_heart/view/RecipeView/RecipeView.dart';

Container recipeCardQuery(
    String url, String title, double calories, LinkedHashMap map) {
  RecipeFeedController c = Get.find();
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
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFF36DC55),
      ),
      child: InkWell(
        onTap: () => Get.to(() => new RecipeView(map)),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 7.0),
                      width: 250.0,
                      child: Text(
                        title,
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                        softWrap: true,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(right: 7.0),
                      child: Text((calories).toInt().toString() + 'kCal',
                          style: TextStyle(
                              color: Color(0xFF36DC55), fontSize: 16.0)),
                    ),
                  ],
                )),
          ],
        ),
      ));
}