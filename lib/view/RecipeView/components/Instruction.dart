import 'package:flutter/material.dart';

Container Instruction(List documents, int index) {
  return Container(
    child: Column(
      children: [
        Text("Step " + documents[index]['number'].toString() + " :"),
        Text(documents[index]['step'])
      ],
    ),
  );
}
