import 'package:flutter/material.dart';

Container Ingredient(List documents, int index) {
  return Container(
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: Colors.green[600]),
      width: 125.0,
      height: 100.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: 100.0,
              child: Text(
                documents[index]["name"],
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                softWrap: true,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Text(
            documents[index]["amount"]["metric"]["value"].toString() +
                " " +
                documents[index]["amount"]["metric"]["unit"].toString(),
            style: TextStyle(color: Colors.white, fontSize: 10.0),
          )
        ],
      ));
}
