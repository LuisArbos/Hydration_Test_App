import 'package:flutter/material.dart';

class BasicModel{
  String name;
  String value;
  Color boxColor;

  BasicModel({
    required this.name,
    required this.value,
    required this.boxColor,
  });

  static List<BasicModel> getBasics() {
    List<BasicModel> basics = [];

    basics.add(
      BasicModel(
        name: 'Temperatura Ambiente', 
        value: '', 
        boxColor: Color(0xffC8E6C9)
        )
    );

    basics.add(
      BasicModel(
        name: 'Temperatura Percibida', 
        value: '', 
        boxColor: Color(0xffC8E6C9)
        )
    );

    basics.add(
      BasicModel(
        name: 'Intensidad', 
        value: '', 
        boxColor: Color(0xffC8E6C9)
        )
    );

    basics.add(
      BasicModel(
        name: 'Humedad', 
        value: '', 
        boxColor: Color(0xffC8E6C9)
        )
    );

    return basics;
  }
}