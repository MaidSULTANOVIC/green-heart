import 'package:flutter/material.dart';

Container Instruction(List documents, int index) {
  return Container(
    child: Column(
      children: [
        Text("Step " + documents[index]['number'].toString() + " :",
            style: TextStyle(
              color: Color(0xFFbf1717),
              fontSize: 15.0,
            )),
        Text(documents[index]['step'])
      ],
    ),
  );
}
