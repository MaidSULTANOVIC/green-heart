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
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
          child: Text(documents[index]['step']),
        )
      ],
    ),
  );
}
